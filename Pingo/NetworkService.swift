//
//  NetworkService.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func execute<T: Decodable>(_ request: URLRequest, responseModel: T.Type) async throws -> T
}

class NetworkService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension NetworkService: NetworkServiceProtocol {
    
    func execute<T: Decodable>(_ request: URLRequest, responseModel: T.Type) async throws -> T {
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            print("Error decoding data: \(error.localizedDescription)")
            throw NetworkError.decodingError
        }
    }
}


