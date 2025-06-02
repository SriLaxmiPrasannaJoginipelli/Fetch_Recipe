//
//  ImageLoader.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation
import SwiftUI

@MainActor
class ImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let url: URL?
    private let urlSession: URLSession
    private let cache = ImageCacheService.shared
    
    init(url: URL?,urlSession: URLSession = .shared) {
        self.url = url
        self.urlSession = urlSession
    }
    
    func loadImage() async {
        guard let url = url else { return }
        
        isLoading = true
        error = nil
        
        // Check cache first
        if let cachedImage = cache.cachedImage(for: url) {
            print("Image loaded from cache")
            image = cachedImage
            isLoading = false
            return
        }
        
        // Network request
        do {
            let (data, _) = try await urlSession.data(from: url)
            guard let loadedImage = UIImage(data: data) else {
                throw NetworkError.invalidData
            }
            
            // Cache and update
            try cache.cacheImage(loadedImage, for: url)
            image = loadedImage
        } catch {
            self.error = error
            print("Load failed: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
