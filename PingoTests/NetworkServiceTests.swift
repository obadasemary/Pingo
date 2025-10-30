//
//  NetworkServiceTests.swift
//  PingoTests
//
//  Created by ChatGPT on 29.10.2025.
//

import Testing
import Foundation
@testable import Pingo

@Suite("Network Service", .serialized)
struct NetworkServiceTests {
    
    @MainActor
    @Test("Execute decodes response when request succeeds with 2xx status")
    func execute_success() async throws {
        let expectedURL = URL(string: "https://example.com/character")!
        let expectedResponse = CharactersPageResponse(
            info: PageInfoResponse(count: 1, pages: 1),
            results: [
                CharacterResponse(
                    id: 1,
                    name: "Rick Sanchez",
                    species: "Human",
                    image: URL(string: "https://example.com/image.png")
                )
            ]
        )
        
        let data = makeCharactersPageJSON()
        URLProtocolStub.reset()
        defer { URLProtocolStub.reset() }
        URLProtocolStub.stubbedHandler = .success((statusCode: 200, data: data))
        
        let sut = makeSUT()
        let request = URLRequest(url: expectedURL)
        
        let response: CharactersPageResponse = try await sut
            .execute(request, responseModel: CharactersPageResponse.self)
        
        #expect(URLProtocolStub.receivedRequests.count == 1)
        #expect(URLProtocolStub.receivedRequests.first?.url == expectedURL)
        #expect(response.info.count == expectedResponse.info.count)
        #expect(response.info.pages == expectedResponse.info.pages)
        #expect(response.results == expectedResponse.results)
    }
    
    @MainActor
    @Test("Execute throws invalidResponse for non-2xx status codes")
    func execute_invalidResponse() async throws {
        let expectedURL = URL(string: "https://example.com/character")!
        URLProtocolStub.reset()
        defer { URLProtocolStub.reset() }
        URLProtocolStub.stubbedHandler = .success((statusCode: 500, data: Data()))
        
        let sut = makeSUT()
        let request = URLRequest(url: expectedURL)
        
        await #expect(throws: NetworkError.invalidResponse) {
            let _: CharactersPageResponse = try await sut.execute(request, responseModel: CharactersPageResponse.self)
        }
        
        #expect(URLProtocolStub.receivedRequests.count == 1)
        #expect(URLProtocolStub.receivedRequests.first?.url == expectedURL)
    }
    
    @MainActor
    @Test("Execute throws decodingError when decoding fails")
    func execute_decodingError() async throws {
        let expectedURL = URL(string: "https://example.com/character")!
        let invalidJSON = Data(#"{"unexpected": "payload"}"#.utf8)
        URLProtocolStub.reset()
        defer { URLProtocolStub.reset() }
        URLProtocolStub.stubbedHandler = .success((statusCode: 200, data: invalidJSON))
        
        let sut = makeSUT()
        let request = URLRequest(url: expectedURL)
        
        await #expect(throws: NetworkError.decodingError) {
            let _: CharactersPageResponse = try await sut.execute(request, responseModel: CharactersPageResponse.self)
        }
        
        #expect(URLProtocolStub.receivedRequests.count == 1)
        #expect(URLProtocolStub.receivedRequests.first?.url == expectedURL)
    }
}

private extension NetworkServiceTests {
    
    func makeCharactersPageJSON() -> Data {
        let json = """
        {
            "info": {
                "count": 1,
                "pages": 1
            },
            "results": [
                {
                    "id": 1,
                    "name": "Rick Sanchez",
                    "species": "Human",
                    "image": "https://example.com/image.png"
                }
            ]
        }
        """
        return Data(json.utf8)
    }
    
    @MainActor
    func makeSUT() -> NetworkService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        return NetworkService(session: session)
    }
}

// MARK: - URLProtocol Stub

private final class URLProtocolStub: URLProtocol {
    
    enum Handler {
        case success((statusCode: Int, data: Data))
        case failure(Error)
    }
    
    static var stubbedHandler: Handler?
    static var receivedRequests: [URLRequest] = []
    
    static func reset() {
        stubbedHandler = nil
        receivedRequests = []
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        if let request = task.currentRequest {
            return canInit(with: request)
        }
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        URLProtocolStub.receivedRequests.append(request)
        
        guard let handler = URLProtocolStub.stubbedHandler else {
            client?.urlProtocol(self, didFailWithError: NetworkError.invalidResponse)
            return
        }
        
        switch handler {
        case .success(let payload):
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: payload.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: payload.data)
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // No-op
    }
}

// MARK: - Test-only Equatable conformance

extension NetworkError: Equatable {}
