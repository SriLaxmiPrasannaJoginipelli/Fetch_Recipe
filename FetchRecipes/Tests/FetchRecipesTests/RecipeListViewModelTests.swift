//
//  RecipeListViewModelTests.swift
//  FetchRecipesTests
//
//  Created by Srilu Rao on 5/31/25.
//

import XCTest
@testable import FetchRecipes

final class RecipeListViewModelTests: XCTestCase {
    private var viewModel: RecipeListViewModel!
    private var mockRecipeService: MockRecipeService!
    
    override func setUp() async throws {
            try await super.setUp()
            mockRecipeService = MockRecipeService()
            viewModel = await RecipeListViewModel(recipeService: mockRecipeService)
        }
    
    func testFetchRecipesSuccess() async {
        // Given
        let testRecipes = [
            Recipe(
                id: UUID(),
                cuisine: "British",
                name: "Bakewell Tart",
                photoURLSmall: nil,
                photoURLLarge: nil,
                sourceURL: nil,
                youtubeURL: nil
            )
        ]
        mockRecipeService.recipes = testRecipes
        
        // When
        await viewModel.fetchRecipes()
        
        // Then
        await MainActor.run {
                XCTAssertEqual(viewModel.recipes.count, 1)
                XCTAssertEqual(viewModel.recipes[0].name, "Bakewell Tart")
                XCTAssertFalse(viewModel.isLoading)
                XCTAssertNil(viewModel.error)
            }
    }
    
    func testFetchRecipesFailure() async {
        // Given
        mockRecipeService.error = NetworkError.invalidResponse
        
        // When
        await viewModel.fetchRecipes()
        
        // Then
        await MainActor.run{
            XCTAssertTrue(viewModel.recipes.isEmpty)
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNotNil(viewModel.error)
            XCTAssertTrue(viewModel.showingErrorAlert)
        }
    }
    
    func testRefreshRecipes() async {
        // Given
        let testRecipes = [
            Recipe(
                id: UUID(),
                cuisine: "British",
                name: "Bakewell Tart",
                photoURLSmall: nil,
                photoURLLarge: nil,
                sourceURL: nil,
                youtubeURL: nil
            )
        ]
        mockRecipeService.recipes = testRecipes
        
        // When
        await viewModel.refreshRecipes()
        
        // Then
        await MainActor.run{
            XCTAssertEqual(viewModel.recipes.count, 1)
            XCTAssertEqual(viewModel.recipes[0].name, "Bakewell Tart")
            XCTAssertFalse(viewModel.isLoading)
            XCTAssertNil(viewModel.error)
        }
    }
    
    func testLoadingState() async {
        let testRecipes = [
            Recipe(
                id: UUID(),
                cuisine: "British",
                name: "Bakewell Tart",
                photoURLSmall: nil,
                photoURLLarge: nil,
                sourceURL: nil,
                youtubeURL: nil
            )
        ]
        mockRecipeService.recipes = testRecipes
        
        let expectation = XCTestExpectation(description: "Loading state updates")
        let cancellable = await viewModel.$isLoading
            .dropFirst()  
            .sink { isLoading in
                if !isLoading {
                    expectation.fulfill()
                }
            }
        
        await viewModel.fetchRecipes()
        await fulfillment(of: [expectation], timeout: 1)
        cancellable.cancel()
    }
    
    
    func testViewModelHandlesEmptyRecipes() async {
        let service = RecipeService()
        let viewModel = await RecipeListViewModel(recipeService: service)
        
        await viewModel.fetchRecipes(from: Endpoints.emptyRecipes)
        print("recipe count \(await viewModel.recipes.count)")  
        
        await MainActor.run {
            XCTAssertTrue(viewModel.recipes.isEmpty)
            XCTAssertNil(viewModel.error)
            XCTAssertFalse(viewModel.showingErrorAlert)
            XCTAssertTrue(viewModel.isEmpty)
        }
    }

    func testViewModelHandlesMalformedRecipes() async {
        let service = RecipeService()
        let viewModel = await RecipeListViewModel(recipeService: service)
        
        await viewModel.fetchRecipes(from: Endpoints.malformedRecipes)
        
        await MainActor.run {
            print("Malformed recipes count: \(viewModel.recipes.count)")
            XCTAssertTrue(viewModel.recipes.isEmpty)
            XCTAssertNotNil(viewModel.error)
            
            if let error = viewModel.error {
                switch error {
                case .malformedData:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Expected malformedData error, got \(error)")
                }
            } else {
                XCTFail("Expected an error but found none")
            }
        }
    }



}

class MockRecipeService: RecipeServiceProtocol {
    var recipes: [Recipe] = []
    var error: Error?
    
    func fetchRecipes(from url: URL) async throws -> [Recipe] {
        if let error = error {
            throw error
        }
        return recipes
    }
}
