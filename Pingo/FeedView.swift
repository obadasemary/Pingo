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
            .navigationTitle("NewFeeds")
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
