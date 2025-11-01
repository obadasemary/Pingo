//
//  FeedRepository.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import Foundation

protocol FeedRepositoryProtocol {
    func fetchFeed(url: URL) async throws -> CharactersPageResponse
}

final class FeedRepository {
    private let networkServiceProtocol: NetworkServiceProtocol

    init(networkServiceProtocol: NetworkServiceProtocol) {
        self.networkServiceProtocol = networkServiceProtocol
    }
}

extension FeedRepository: FeedRepositoryProtocol {
    func fetchFeed(url: URL) async throws -> CharactersPageResponse {
        try await networkServiceProtocol
            .execute(
                .init(url: url),
                responseModel: CharactersPageResponse.self
            )
    }
}
