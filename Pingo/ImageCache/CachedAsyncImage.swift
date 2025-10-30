//
//  CachedAsyncImage.swift
//  Pingo
//
//  Created by ChatGPT on 2025-02-15.
//

import SwiftUI
import Combine
import UIKit

enum ImageLoadPhase {
    case empty
    case success(Image)
    case failure(Error?)
}

@MainActor
final class ImageLoader: ObservableObject {
    
    @Published private(set) var phase: ImageLoadPhase = .empty
    
    private let cache: ImageCacheProtocol
    private var task: Task<Void, Never>?
    private var url: URL?
    
    init(url: URL?, cache: ImageCacheProtocol = ImageCache.shared) {
        self.url = url
        self.cache = cache
    }
    
    func update(url: URL?) {
        guard self.url != url else { return }
        task?.cancel()
        task = nil
        phase = .empty
        self.url = url
    }
    
    func load() {
        guard task == nil else { return }
        guard let url else {
            phase = .failure(nil)
            return
        }
        
        if let cachedImage = cache[url] {
            phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        task = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return }
                
                guard let image = UIImage(data: data) else {
                    await MainActor.run {
                        self.phase = .failure(nil)
                        self.task = nil
                    }
                    return
                }
                
                await MainActor.run {
                    self.cache[url] = image
                    self.phase = .success(Image(uiImage: image))
                    self.task = nil
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    self.phase = .failure(error)
                    self.task = nil
                }
            }
        }
    }
    
    func cancel() {
        task?.cancel()
        task = nil
    }
}

struct CachedAsyncImage<Content: View>: View {
    
    private let url: URL?
    private let content: (ImageLoadPhase) -> Content
    
    @StateObject private var loader: ImageLoader
    @State private var currentURL: URL?
    
    init(
        url: URL?,
        cache: ImageCacheProtocol = ImageCache.shared,
        @ViewBuilder content: @escaping (ImageLoadPhase) -> Content
    ) {
        self.url = url
        self.content = content
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: cache))
        _currentURL = State(initialValue: url)
    }
    
    var body: some View {
        content(loader.phase)
            .onAppear {
                loader.load()
            }
            .onChange(of: url) { newURL in
                guard currentURL != newURL else { return }
                currentURL = newURL
                loader.update(url: newURL)
                loader.load()
            }
            .onDisappear {
                loader.cancel()
            }
    }
}
