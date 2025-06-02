//
//  RecipeDetailViewModel.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation
import SwiftUI

@MainActor
class RecipeDetailViewModel: ObservableObject {
    @Published var isLoadingImage = false
    @Published var imageError: Error?
    
    private let recipe: Recipe
    private let imageLoader: ImageLoader
    
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.imageLoader = ImageLoader(url: recipe.photoURLLarge)
    }
    
    func loadImage() async {
        await imageLoader.loadImage()
        isLoadingImage = imageLoader.isLoading
        imageError = imageLoader.error
    }
    
    var recipeName: String { recipe.name }
    var cuisine: String { recipe.cuisine }
    var sourceURL: URL? { recipe.sourceURL }
    var youtubeURL: URL? { recipe.youtubeURL }
    var image: UIImage? { imageLoader.image }
}
