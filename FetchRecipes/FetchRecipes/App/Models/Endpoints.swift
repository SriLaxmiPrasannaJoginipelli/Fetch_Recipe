//
//  Endpoints.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation


enum Endpoints {
    static let baseURL = "https://d3jbb8n5wk0qxi.cloudfront.net"
    
    static var recipes: URL {
        URL(string: "\(baseURL)/recipes.json")!
    }
    
    static var malformedRecipes: URL {
        URL(string: "\(baseURL)/recipes-malformed.json")!
    }
    
    static var emptyRecipes: URL {
        URL(string: "\(baseURL)/recipes-empty.json")!
    }
}
