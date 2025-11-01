//
//  FeedUseCaseTests.swift
//  PingoTests
//
//  Created by ChatGPT on 28.10.2025.
//

import Foundation
@testable import Pingo
import Testing

struct FeedUseCaseTests {
    @MainActor
    @Test("Fetch feed succeeds and forwards repository response")
    func fetchFeed_success() async throws {
        let expectedURL = URL(string: "https://example.com/feed")!
        let expectedResponse = CharactersPageResponse(
            info: PageInfoResponse(count: 1, pages: 1),
            results: [
                CharacterResponse(id: 1, name: "Rick", species: "Human", image: nil),
            ]
        )

        let repository = MockFeedRepository(result: .success(expectedResponse))
        let sut = FeedUseCase(feedRepository: repository)

        let response = try await sut.fetchFeed(url: expectedURL)

        #expect(repository.fetchFeedCallCount == 1)
        #expect(repository.receivedURLs == [expectedURL])
        #expect(response.info.count == expectedResponse.info.count)
        #expect(response.info.pages == expectedResponse.info.pages)
        #expect(response.results == expectedResponse.results)
    }

    @MainActor
    @Test("Fetch feed fails and forwards repository error")
    func fetchFeed_failure() async throws {
        let expectedURL = URL(string: "https://example.com/feed")!
        let repository = MockFeedRepository(result: .failure(MockError.stub))
        let sut = FeedUseCase(feedRepository: repository)

        await #expect(throws: MockError.stub) {
            try await sut.fetchFeed(url: expectedURL)
        }

        #expect(repository.fetchFeedCallCount == 1)
        #expect(repository.receivedURLs == [expectedURL])
    }
}

private extension FeedUseCaseTests {
    enum MockError: Error, Equatable {
        case stub
    }

    final class MockFeedRepository: FeedRepositoryProtocol {
        private let result: Result<CharactersPageResponse, Error>
        private(set) var fetchFeedCallCount = 0
        private(set) var receivedURLs: [URL] = []

        init(result: Result<CharactersPageResponse, Error>) {
            self.result = result
        }

        func fetchFeed(url: URL) async throws -> CharactersPageResponse {
            fetchFeedCallCount += 1
            receivedURLs.append(url)

            switch result {
            case let .success(response):
                return response
            case let .failure(error):
                throw error
            }
        }
    }
}
