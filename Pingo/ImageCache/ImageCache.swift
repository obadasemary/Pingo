//
//  ImageCache.swift
//  Pingo
//
//  Created by ChatGPT on 2025-02-15.
//

import UIKit

protocol ImageCacheProtocol: AnyObject {
    subscript(_ url: URL) -> UIImage? { get set }
}

final class ImageCache: ImageCacheProtocol {
    
    static let shared = ImageCache()
    
    private let cache: NSCache<NSURL, UIImage>
    
    private init() {
        cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    subscript(_ url: URL) -> UIImage? {
        get { cache.object(forKey: url as NSURL) }
        set {
            let key = url as NSURL
            if let image = newValue {
                cache.setObject(image, forKey: key)
            } else {
                cache.removeObject(forKey: key)
            }
        }
    }
}
