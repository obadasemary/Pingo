//
//  FeedEntity.swift
//  Pingo
//
//  Created by Abdelrahman Mohamed on 27.10.2025.
//

import Foundation

struct CharactersPageResponse: Decodable, Sendable {
    let info: PageInfoResponse
    let results: [CharacterResponse]
}

struct PageInfoResponse: Decodable, Sendable {
    let count: Int
    let pages: Int
}

struct CharacterResponse: Decodable, Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let species: String?
    let image: URL?
}
