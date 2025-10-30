//
//  FeedRepositoryTests.swift
//  PingoTests
//
//  Created by ChatGPT on 29.10.2025.
//

import Testing
import Foundation
@testable import Pingo

struct FeedRepositoryTests {
    
    @MainActor
    @Test("Fetch feed forwards request to network service and returns decoded response")
    func fetchFeed_success() async throws {
        let expectedURL = URL(string: "https://example.com/characters")!
        let expectedResponse = CharactersPageResponse(
            info: PageInfoResponse(count: 20, pages: 5),
            results: [
                CharacterResponse(id: 1, name: "Rick Sanchez", species: "Human", image: nil)
            ]
        )
        
        let networkService = MockNetworkService(result: .success(expectedResponse))
        let sut = FeedRepository(networkServiceProtocol: networkService)
        
        let response = try await sut.fetchFeed(url: expectedURL)
        
        #expect(networkService.executeCallCount == 1)
        #expect(networkService.receivedRequests.count == 1)
        #expect(networkService.receivedRequests.first?.url == expectedURL)
        #expect(response.info.count == expectedResponse.info.count)
        #expect(response.info.pages == expectedResponse.info.pages)
        #expect(response.results == expectedResponse.results)
    }
    
    @MainActor
    @Test("Fetch feed forwards network error")
    func fetchFeed_failure() async throws {
        let expectedURL = URL(string: "https://example.com/characters")!
        let networkService = MockNetworkService(result: .failure(MockError.stub))
        let sut = FeedRepository(networkServiceProtocol: networkService)
        
        await #expect(throws: MockError.stub) {
            _ = try await sut.fetchFeed(url: expectedURL)
        }
        
        #expect(networkService.executeCallCount == 1)
        #expect(networkService.receivedRequests.first?.url == expectedURL)
    }
}

private extension FeedRepositoryTests {
    
    enum MockError: Error, Equatable {
        case stub
    }
    
    final class MockNetworkService: NetworkServiceProtocol {
        
        private let result: Result<CharactersPageResponse, Error>
        private(set) var executeCallCount = 0
        private(set) var receivedRequests: [URLRequest] = []
        
        init(result: Result<CharactersPageResponse, Error>) {
            self.result = result
        }
        
        func execute<T: Decodable>(_ request: URLRequest, responseModel: T.Type) async throws -> T {
            executeCallCount += 1
            receivedRequests.append(request)
            
            switch result {
            case .success(let response):
                guard let typedResponse = response as? T else {
                    throw MockError.stub
                }
                return typedResponse
            case .failure(let error):
                throw error
            }
        }
    }
}
