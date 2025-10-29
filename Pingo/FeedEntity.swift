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
    
    init(info: PageInfoResponse, results: [CharacterResponse]) {
        self.info = info
        self.results = results
    }
}

struct PageInfoResponse: Decodable, Sendable {
    
    let count: Int
    let pages: Int
    
    enum CodingKeys: CodingKey {
        case count
        case pages
    }
    
    init(count: Int, pages: Int) {
        self.count = count
        self.pages = pages
    }
}

struct CharacterResponse: Decodable, Identifiable, Equatable, Sendable {
    
    let id: Int
    let name: String
    let species: String?
    let image: URL?
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case species
        case image
    }
    
    init (
        id: Int,
        name: String,
        species: String?,
        image: URL?
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.image = image
    }
}
