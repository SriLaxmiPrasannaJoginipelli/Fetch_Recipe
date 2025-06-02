//
//  RecipeListView.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import SwiftUI

struct RecipeListView: View {
    @StateObject private var viewModel = RecipeListViewModel()
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let error = viewModel.error {
                    ErrorView(error: error) {
                        Task {
                            await refreshData()
                        }
                    }
                }
                else if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.recipes.isEmpty {
                    emptyStateView
                } else {
                    recipeList
                }
            }
            .navigationTitle(viewModel.error == nil && viewModel.recipes.count > 0 ? "Recipes" : "")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    refreshButton
                    
                }
            }
            .alert("Error", isPresented: $viewModel.showingErrorAlert) {
                Button("OK") {}
            } message: {
                Text(viewModel.error?.errorDescription ?? "Unknown error occurred")
            }
            .task {
                await viewModel.fetchRecipes()
            }
            
            /*
             Testing purpose only - Debug button to clear image cache
             */
            
            //            .toolbar {
            //                ToolbarItem(placement: .navigationBarLeading) {
            //                    Button("Clear Cache") {
            //                        try? ImageCacheService.shared.clearCache()
            //                    }
            //                }
            //            }
        }
        
    }
    
    private var recipeList: some View {
        List(viewModel.recipes) { recipe in
            NavigationLink {
                RecipeDetailView(recipe: recipe)
            } label: {
                RecipeRowView(recipe: recipe)
            }
        }
        .refreshable {
            await viewModel.refreshRecipes()
        }
        .opacity(isRefreshing ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isRefreshing)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No recipes available")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button("Try Again") {
                Task {
                    await viewModel.refreshRecipes()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var refreshButton: some View {
        Button {
            Task {
                await refreshData()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                .animation(
                    isRefreshing
                    ? .linear(duration: 1).repeatForever(autoreverses: false)
                    : .default,
                    value: isRefreshing
                )
        }
        .disabled(isRefreshing)
    }
    
    private func refreshData() async {
        withAnimation {
            isRefreshing = true
            viewModel.error = nil
        }
        await viewModel.refreshRecipes()
        
        withAnimation {
            isRefreshing = false
        }
    }
}
#Preview {
    RecipeListView()
}
