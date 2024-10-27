//
//  FeedUseCase.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import Foundation

protocol FeedUseCaseProtocol {
    func fetchFeed(url: URL) async throws -> CharactersPageResponse
}

final class FeedUseCase {
    
    private let feedRepository: FeedRepositoryProtocol
    
    init(feedRepository: FeedRepositoryProtocol) {
        self.feedRepository = feedRepository
    }
}

extension FeedUseCase: FeedUseCaseProtocol {
    
    func fetchFeed(url: URL) async throws -> CharactersPageResponse {
        try await feedRepository.fetchFeed(url: url)
    }
}
