//
//  RecipeServiceTests.swift
//  FetchRecipesTests
//
//  Created by Srilu Rao on 5/31/25.
//

import XCTest
@testable import FetchRecipes


final class RecipeServiceTests: XCTestCase {
    private var recipeService: RecipeService!
    private var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        recipeService = RecipeService(session: mockSession)
    }
    
    func testFetchRecipesSuccess() async {
        // Given
        let json = """
        {
            "recipes": [
                {
                    "cuisine": "British",
                    "name": "Bakewell Tart",
                    "photo_url_small": "https://example.com/small.jpg",
                    "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6"
                }
            ]
        }
        """
        mockSession.data = json.data(using: .utf8)
        mockSession.response = HTTPURLResponse(
            url: Endpoints.recipes,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        do {
            let recipes = try await recipeService.fetchRecipes(from: Endpoints.recipes)
            
            // Then
            XCTAssertEqual(recipes.count, 1)
            XCTAssertEqual(recipes[0].name, "Bakewell Tart")
        } catch {
            XCTFail("Expected successful fetch, got error: \(error)")
        }
    }
    
    func testFetchRecipesMalformedData() async {
        // Given
        let json = """
        {
            "recipes": [
                {    
                    "name": "Bakewell Tart",
                    "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6"
                }
            ]
        }
        """
        mockSession.data = json.data(using: .utf8)
        mockSession.response = HTTPURLResponse(
            url: Endpoints.recipes,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        do {
            _ = try await recipeService.fetchRecipes(from: Endpoints.recipes)
            XCTFail("Expected malformed data error")
        } catch {
            // Then
            XCTAssertTrue(error is NetworkError)
            if case .malformedData = error as? NetworkError {
                // Success for manual validation approach
            } else if case .decodingError = error as? NetworkError {
                // Success for non-optional model approach
            } else {
                XCTFail("Expected malformedData or decodingError, got \(error)")
            }
        }
    }
    func testFetchRecipesEmptyData() async {
        // Given
        let json = """
        {
            "recipes": []
        }
        """
        mockSession.data = json.data(using: .utf8)
        mockSession.response = HTTPURLResponse(
            url: Endpoints.recipes,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        do {
            _ = try await recipeService.fetchRecipes(from: Endpoints.recipes)
            XCTFail("Expected empty data error")
        } catch {
            // Then
            XCTAssertTrue(error is NetworkError)
            if case .emptyData = error as? NetworkError {
                // Success
            } else {
                XCTFail("Expected emptyData error")
            }
        }
    }
    
    func testFetchRecipesServerError() async {
            // Given
            mockSession.response = HTTPURLResponse(
                url: Endpoints.recipes,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )
            
            // When
            do {
                _ = try await recipeService.fetchRecipes(from: Endpoints.recipes)
                XCTFail("Expected server error")
            } catch {
                // Then
                XCTAssertTrue(error is NetworkError)
                if case .serverError(let code) = error as? NetworkError {
                    XCTAssertEqual(code, 500)
                } else {
                    XCTFail("Expected serverError, got \(error)")
                }
            }
        }
    
    func testDecodingWithOptionalFields() async {
        // Given
        let json = """
        {
            "recipes": [
                {
                    "cuisine": "British",
                    "name": "Bakewell Tart",
                    "uuid": "eed6005f-f8c8-451f-98d0-4088e2b40eb6"
                }
            ]
        }
        """
        mockSession.data = json.data(using: .utf8)
        mockSession.response = HTTPURLResponse(
            url: Endpoints.recipes,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let recipes = try? await recipeService.fetchRecipes(from: Endpoints.recipes)
        
        // Then
        XCTAssertEqual(recipes?.count, 1)
        XCTAssertEqual(recipes?.first?.name, "Bakewell Tart")
        XCTAssertNil(recipes?.first?.photoURLSmall)  
    }
}

class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    var requestCount = 0
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requestCount += 1
        
        // If we have an explicit error to throw, throw it
        if let error = error {
            throw error
        }
        
        // If we don't have a response, throw a generic error
        guard let response = response else {
            throw URLError(.badServerResponse)
        }
        
        if let httpResponse = response as? HTTPURLResponse,
           (400...599).contains(httpResponse.statusCode) {
            // Return the error response with the status code
            return (data ?? Data(), httpResponse)
        }
        
        // For successful responses, return data if available
        guard let data = data else {
            throw URLError(.cannotParseResponse)
        }
        
        return (data, response)
    }
}
