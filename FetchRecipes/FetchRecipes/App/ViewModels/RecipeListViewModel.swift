//
//  RecipeListViewModel.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation

@MainActor
class RecipeListViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var error: NetworkError?
    @Published var showingErrorAlert = false
    @Published var isEmpty = false
    
    private let recipeService: RecipeServiceProtocol
    
    init(recipeService: RecipeServiceProtocol = RecipeService()) {
        self.recipeService = recipeService
    }
    
    func fetchRecipes(from url: URL = Endpoints.recipes) async {
        isLoading = true
        error = nil
        isEmpty = false
        
        do {
            let fetchedRecipes = try await recipeService.fetchRecipes(from: url)
            recipes = fetchedRecipes
            isEmpty = fetchedRecipes.isEmpty
        } catch let error as NetworkError {
            self.error = error
            showingErrorAlert = true
            recipes = []
            isEmpty = false
        } catch {
            self.error = .invalidData
            showingErrorAlert = true
            recipes = []
            isEmpty = false
        }
        
        isLoading = false
    }
    
    func refreshRecipes() async {
        await fetchRecipes()
    }
}
