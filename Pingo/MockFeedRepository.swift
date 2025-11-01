//
//  MockFeedRepository.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import Foundation

class MockFeedRepository: FeedRepositoryProtocol {
    func fetchFeed(url _: URL) async throws -> CharactersPageResponse {
        CharactersPageResponse(
            info: PageInfoResponse(count: 826, pages: 42),
            results: [
                CharacterResponse(
                    id: 1,
                    name: "Obada",
                    species: "Human",
                    image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
                ),
                CharacterResponse(
                    id: 2,
                    name: "Sofa",
                    species: "Human",
                    image: URL(string: "https://rickandmortyapi.com/api/character/avatar/2.jpeg")
                ),
                CharacterResponse(
                    id: 3,
                    name: "rick",
                    species: "Human",
                    image: URL(string: "https://rickandmortyapi.com/api/character/avatar/3.jpeg")
                ),
            ]
        )
    }
}
