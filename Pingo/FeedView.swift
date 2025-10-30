//
//  FeedView.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import SwiftUI

struct FeedView: View {
    
    @State var viewModel: FeedViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.characters, id: \.id) { character in
                        NavigationLink {
                            FeedViewDetails(character: character)
                        } label: {
                            CharacterView(character: character)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .overlay(alignment: .top) {
                if let message = viewModel.errorMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(.thinMaterial)
                        .shadow(radius: 2)
                        .padding()
                }
            }
            .navigationTitle("NewFeeds")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gear")
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
                }
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
}

#Preview {
    let feedBuilder = FeedBuilder()
    feedBuilder.buildFeedView(usingMock: true)
}
