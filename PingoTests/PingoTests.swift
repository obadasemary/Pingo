//
//  PingoTests.swift
//  PingoTests
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import Testing
import Foundation
@testable import Pingo

@Suite
struct FeedViewModelTests {
    
    @MainActor
    @Test
    func fetchCharacters_populatesCharacters_onSuccess() async throws {
        let expectedCharacters = [
            CharacterResponse(id: 1, name: "Rick", species: "Human", image: nil),
            CharacterResponse(id: 2, name: "Morty", species: "Alien", image: nil)
        ]
        let mockUseCase = MockFeedUseCase(result: .success(
            CharactersPageResponse(
                info: PageInfoResponse(count: 2, pages: 1),
                results: expectedCharacters
            )
        ))
        let viewModel = FeedViewModel(feedUseCase: mockUseCase)
        
        await viewModel.loadData()
        
        #expect(viewModel.characters == expectedCharacters)
    }
    
    @MainActor
    @Test
    func fetchCharacters_keepsCharactersEmpty_onFailure() async throws {
        let mockUseCase = MockFeedUseCase(result: .failure(MockError.stub))
        let viewModel = FeedViewModel(feedUseCase: mockUseCase)
        
        await viewModel.loadData()
        
        #expect(viewModel.characters.isEmpty)
    }
}

private extension FeedViewModelTests {
    
    enum MockError: Error {
        case stub
    }
    
    final class MockFeedUseCase: FeedUseCaseProtocol {
        private let result: Result<CharactersPageResponse, Error>
        
        init(result: Result<CharactersPageResponse, Error>) {
            self.result = result
        }
        
        func fetchFeed(url: URL) async throws -> CharactersPageResponse {
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
    }
}
