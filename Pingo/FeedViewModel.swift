//
//  FeedViewModel.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import Foundation

@Observable
final class FeedViewModel {
    
    private let feedUseCase: FeedUseCaseProtocol
    let url = URL(string: "https://rickandmortyapi.com/api/character")
    
    private(set) var characters: [CharacterResponse] = []
    
    init(feedUseCase: FeedUseCaseProtocol) {
        self.feedUseCase = feedUseCase
    }
    
    func loadData() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            try await self.fetchCharacters()
        }
    }
    
    func fetchCharacters() async throws {
        
        guard let url else { return }
        
        do {
            let reponse = try await feedUseCase.fetchFeed(url: url)
            characters = reponse.results
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}
