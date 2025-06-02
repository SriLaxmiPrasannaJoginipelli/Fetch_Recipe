//
//  ImageCacheService.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 5/31/25.
//

import Foundation
import UIKit
import CryptoKit

protocol ImageCacheServiceProtocol {
    func cacheImage(_ image: UIImage, for url: URL) throws
    func cachedImage(for url: URL) -> UIImage?
    func clearCache() throws
    func removeImage(for url: URL) throws
    func clearMemoryCache()
}

final class ImageCacheService: ImageCacheServiceProtocol {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let cacheExpiration: TimeInterval = 7 * 24 * 60 * 60 // 1 week
    private let serialQueue = DispatchQueue(label: "image.cache.queue", qos: .utility, attributes: .concurrent)
    
    static let shared = ImageCacheService()
    
    init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("ImageCache", isDirectory: true)
        
        // Configure memory cache
        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 200 * 1024 * 1024 // 200MB
        
        setupCacheDirectory()
    }
    
    var cacheCountLimit: Int {
            get { memoryCache.countLimit }
            set { memoryCache.countLimit = newValue }
        }
    
    private func setupCacheDirectory() {
        do {
            try fileManager.createDirectory(at: cacheDirectory,
                                           withIntermediateDirectories: true)
        } catch {
            print("Failed to create cache directory: \(error)")
        }
    }
    
    private func cacheKey(for url: URL) -> String {
        return url.absoluteString.md5Hash
    }
    
     func fileURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }
    
    // MARK: - Public Interface
    
    func cacheImage(_ image: UIImage, for url: URL) throws {
        let key = cacheKey(for: url)
        let fileURL = fileURL(for: key)
        
        // Memory cache
        memoryCache.setObject(image, forKey: key as NSString, cost: image.cost)
        
        // Disk cache (async with barrier)
        try serialQueue.sync(flags: .barrier) {
            if let data = image.pngData() {
                do {
                    try data.write(to: fileURL, options: [.atomic])
                    try fileManager.setAttributes(
                        [.modificationDate: Date()],
                        ofItemAtPath: fileURL.path
                    )
                } catch {
                    throw CacheError.diskWriteFailed(error)
                }
            }
        }
    }
    
    func cachedImage(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)
        
        // Debug: Log the cache key being used
        debugPrint("Checking cache for key: \(key)")
        
        // Check memory cache first
        if let image = memoryCache.object(forKey: key as NSString) {
            debugPrint("Memory cache HIT for key: \(key)")
            
            // Verify disk cache hasn't expired
            let fileURL = fileURL(for: key)
            if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let modDate = attributes[.modificationDate] as? Date {
                
                let age = Date().timeIntervalSince(modDate)
                debugPrint("Disk cache age: \(age) seconds (max: \(cacheExpiration))")
                
                if age > cacheExpiration {
                    debugPrint("Cache EXPIRED - removing from both caches for key: \(key)")
                    memoryCache.removeObject(forKey: key as NSString)
                    try? fileManager.removeItem(at: fileURL)
                    return nil
                }
            }
            return image
        } else {
            debugPrint("Memory cache MISS for key: \(key)")
        }
        
        // Check disk cache
        return serialQueue.sync {
            let fileURL = fileURL(for: key)
            debugPrint("Checking disk cache at: \(fileURL.path)")
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                debugPrint("Disk cache MISS (file not found) for key: \(key)")
                return nil
            }
            
            // Check expiration
            if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
               let modDate = attributes[.modificationDate] as? Date {
                
                let age = Date().timeIntervalSince(modDate)
                debugPrint("Disk cache age: \(age) seconds (max: \(cacheExpiration))")
                
                if age > cacheExpiration {
                    debugPrint("Disk cache EXPIRED - removing for key: \(key)")
                    try? fileManager.removeItem(at: fileURL)
                    return nil
                }
            } else {
                debugPrint("Could not read file attributes for key: \(key)")
            }
            
            // Load image data
            guard let data = try? Data(contentsOf: fileURL) else {
                debugPrint("Failed to read data from disk for key: \(key)")
                try? fileManager.removeItem(at: fileURL)
                return nil
            }
            
            guard let image = UIImage(data: data) else {
                debugPrint("Data corrupted - removing bad file for key: \(key)")
                try? fileManager.removeItem(at: fileURL)
                return nil
            }
            
            debugPrint("Loaded from disk - storing in memory cache for key: \(key)")
            memoryCache.setObject(image, forKey: key as NSString, cost: image.cost)
            return image
        }
    }
    
    func removeImage(for url: URL) throws {
        let key = cacheKey(for: url)
        
        // Remove from memory
        memoryCache.removeObject(forKey: key as NSString)
        
        // Remove from disk
        try serialQueue.sync(flags: .barrier) {
            let fileURL = fileURL(for: key)
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    func clearMemoryCache() {
            memoryCache.removeAllObjects()
        }
    
    func clearCache() throws {
        // Clear memory cache
        memoryCache.removeAllObjects()
        
        // Clear disk cache
        try serialQueue.sync(flags: .barrier) {
            let contents = try fileManager.contentsOfDirectory(at: cacheDirectory,
                                                             includingPropertiesForKeys: nil)
            for fileURL in contents {
                try fileManager.removeItem(at: fileURL)
            }
        }
    }
}

// MARK: - Extensions

extension UIImage {
    var cost: Int {
        guard let cgImage = cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}

extension String {
    var md5Hash: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

// MARK: - Error Handling

enum CacheError: Error {
    case diskWriteFailed(Error)
    case diskReadFailed(Error)
    case cacheDirectoryCreationFailed(Error)
}
