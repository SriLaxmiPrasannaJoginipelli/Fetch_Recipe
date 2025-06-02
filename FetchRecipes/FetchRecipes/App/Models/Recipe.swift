//
//  Recipe.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation

struct Recipe: Identifiable, Codable, Equatable {
    let id: UUID
    let cuisine: String
    let name: String
    let photoURLSmall: URL?
    let photoURLLarge: URL?
    let sourceURL: URL?
    let youtubeURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case cuisine, name
        case photoURLSmall = "photo_url_small"
        case photoURLLarge = "photo_url_large"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
}

struct RecipeResponse: Codable {
    let recipes: [Recipe]
}
