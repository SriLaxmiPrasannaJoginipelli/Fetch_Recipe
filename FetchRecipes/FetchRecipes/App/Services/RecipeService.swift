//
//  RecipeService.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation

protocol RecipeServiceProtocol {
    func fetchRecipes(from url: URL) async throws -> [Recipe]
}
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
class RecipeService: RecipeServiceProtocol {
    private let session: URLSessionProtocol
    private let baseURL: URL
    
    init(session: URLSessionProtocol = URLSession.shared, baseURL: URL = Endpoints.recipes) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func fetchRecipes(from url: URL) async throws -> [Recipe] {
        
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
            
            // Validate all recipes have required fields
            if response.recipes.contains(where: { recipe in
                recipe.name.isEmpty || recipe.cuisine == nil
            }) {
                throw NetworkError.malformedData
            }
            
            //            if response.recipes.isEmpty {
            //                throw NetworkError.emptyData
            //            }
            
            return response.recipes
        } catch let error as DecodingError {
            switch error {
            case .keyNotFound, .typeMismatch, .valueNotFound:
                throw NetworkError.malformedData
            default:
                throw NetworkError.decodingError(error)
            }
        } catch {
            throw error
        }
    }
}
extension URLSession: URLSessionProtocol {}
