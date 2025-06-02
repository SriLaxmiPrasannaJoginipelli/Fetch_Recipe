//
//  RecipeRowView.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe
    @StateObject private var imageLoader = ImageLoader(url: nil)
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _imageLoader = StateObject(wrappedValue: ImageLoader(url: recipe.photoURLSmall))
    }
    
    var body: some View {
        HStack(spacing: 16) {
            recipeImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await imageLoader.loadImage()
        }
    }
    
    private var recipeImage: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if imageLoader.isLoading {
                ProgressView()
                    .frame(width: 60, height: 60)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

//#Preview {
//    RecipeRowView()
//}
