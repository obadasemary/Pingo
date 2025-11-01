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
    private(set) var errorMessage: String?

    init(feedUseCase: FeedUseCaseProtocol) {
        self.feedUseCase = feedUseCase
    }

    func loadData() async {
        do {
            errorMessage = nil
            try await fetchCharacters()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchCharacters() async throws {
        guard let url else { return }

        let response = try await feedUseCase.fetchFeed(url: url)
        characters = response.results
    }
}
