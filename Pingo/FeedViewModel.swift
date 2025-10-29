//
//  FeedViewModel.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import Foundation

@MainActor
@Observable
final class FeedViewModel {
    
    private let feedUseCase: FeedUseCaseProtocol
    let url = URL(string: "https://rickandmortyapi.com/api/character")
    
    private(set) var characters: [CharacterResponse] = []
    
    init(feedUseCase: FeedUseCaseProtocol) {
        self.feedUseCase = feedUseCase
    }
    
    func loadData() async {
        do {
            try await fetchCharacters()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func fetchCharacters() async throws {
        
        guard let url else { return }
        
        let response = try await feedUseCase.fetchFeed(url: url)
        characters = response.results
    }
}
