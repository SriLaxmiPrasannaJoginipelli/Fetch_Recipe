//
//  NetworkError.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodingError(Error)
    case serverError(statusCode: Int)
    case emptyData
    case malformedData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid server response"
        case .invalidData: return "Invalid data received"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .serverError(let statusCode): return "Server error with status code: \(statusCode)"
        case .emptyData: return "No recipes available"
        case .malformedData: return "Recipe data is malformed"
        }
    }
}
