//
//  RecipeDetailView.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @StateObject private var viewModel: RecipeDetailViewModel
    
    init(recipe: Recipe) {
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: recipe))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                recipeImage
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.recipeName)
                        .font(.title.bold())
                    
                    Text(viewModel.cuisine)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                linksSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadImage()
        }
    }
    
    private var recipeImage: some View {
        Group {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()
            } else if viewModel.isLoadingImage {
                ProgressView()
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.gray)
                    .background(Color(.systemGroupedBackground))
            }
        }
    }
    
    private var linksSection: some View {
        Group {
            if let sourceURL = viewModel.sourceURL {
                Link(destination: sourceURL) {
                    Label("View Original Recipe", systemImage: "link")
                }
                .padding()
            }
            
            if let youtubeURL = viewModel.youtubeURL {
                Link(destination: youtubeURL) {
                    Label("Watch on YouTube", systemImage: "play.rectangle")
                }
                .padding()
            }
        }
    }
}

//#Preview {
//    RecipeDetailView()
//}
