//
//  PingoFeedViewModelTests.swift
//  PingoTests
//
//  Created by Abdelrahman Mohamed on 28.10.2025.
//

import Foundation
@testable import Pingo
import Testing

struct PingoFeedViewModelTests {
    @MainActor
    @Test("Fetch Characters On Success")
    func fetchCharacters_onSuccess() async throws {
        let expectedResponse = [
            CharacterResponse(
                id: 1,
                name: "Obada",
                species: "Human",
                image: nil
            ),
            CharacterResponse(
                id: 2,
                name: "Moon",
                species: "Alien",
                image: nil
            ),
        ]

        let makeSut = {
            MockPingoFeedUseCase(
                result:
                .success(
                    CharactersPageResponse(
                        info: PageInfoResponse(
                            count: 2,
                            pages: 1
                        ),
                        results: expectedResponse
                    )
                )
            )
        }

        let viewModel = FeedViewModel(feedUseCase: makeSut())

        await viewModel.loadData()

        #expect(viewModel.characters == expectedResponse)
    }

    @MainActor
    @Test("Fetch Characters on Failure")
    func fetchCharacters_WithEmptyResult_onFailure() async throws {
        let makeSut = {
            MockPingoFeedUseCase(result: .failure(MockError.stub))
        }

        let viewModel = FeedViewModel(feedUseCase: makeSut())

        await viewModel.loadData()

        #expect(viewModel.characters.isEmpty)
    }
}

private extension PingoFeedViewModelTests {
    enum MockError: Error {
        case stub
    }

    final class MockPingoFeedUseCase: FeedUseCaseProtocol {
        private let result: Result<CharactersPageResponse, Error>

        init(result: Result<CharactersPageResponse, Error>) {
            self.result = result
        }

        func fetchFeed(url _: URL) async throws -> CharactersPageResponse {
            switch result {
            case let .success(response):
                return response
            case let .failure(error):
                throw error
            }
        }
    }
}
