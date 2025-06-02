//
//  ImageCacheServiceTests.swift
//  FetchRecipesTests
//
//  Created by Srilu Rao on 5/31/25.
//

import XCTest
@testable import FetchRecipes

class ImageCacheServiceTests: XCTestCase {
    var cacheService: ImageCacheService!
    let testImage = UIImage(systemName: "photo")!
    let testURL = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg")!
    
    override func setUp() {
        super.setUp()
        cacheService = ImageCacheService()
        try? cacheService.clearCache()
    }
    
    
    func testCacheAndRetrieve() throws {
        // Cache the image
        try cacheService.cacheImage(testImage, for: testURL)
        
        // Retrieve from cache
        let cachedImage = cacheService.cachedImage(for: testURL)
        XCTAssertNotNil(cachedImage)
        XCTAssertEqual(cachedImage?.size, testImage.size)
    }
    
    func testMemoryCache() throws {
        try cacheService.cacheImage(testImage, for: testURL)
        
        let firstRetrieval = cacheService.cachedImage(for: testURL)
        XCTAssertNotNil(firstRetrieval)
        
        
        cacheService.clearMemoryCache()
        
        let secondRetrieval = cacheService.cachedImage(for: testURL)
        XCTAssertNotNil(secondRetrieval)
    }
    
    func testCacheExpiration() throws {
        // Cache the image
        try cacheService.cacheImage(testImage, for: testURL)
        
        let key = testURL.absoluteString.md5Hash
        let fileURL = cacheService.fileURL(for: key)
        
        // Modify date to be expired
        let oldDate = Date(timeIntervalSinceNow: -8 * 24 * 60 * 60)
        try FileManager.default.setAttributes(
            [.modificationDate: oldDate],
            ofItemAtPath: fileURL.path
        )
        
        // Clear memory cache to force disk check
        cacheService.clearMemoryCache()
        
        // Should be nil after expiration
        let cachedImage = cacheService.cachedImage(for: testURL)
        XCTAssertNil(cachedImage, "Image should be nil after expiration")
        
        // Verifying  file was removed by trying to access again
        let shouldBeNil = cacheService.cachedImage(for: testURL)
        XCTAssertNil(shouldBeNil, "File should have been removed from disk")
    }
    
    func testConcurrentAccess() {
        let queue = DispatchQueue(label: "test.queue", attributes: .concurrent)
        let group = DispatchGroup()
        
        for i in 0..<100 {
            group.enter()
            queue.async {
                let url = URL(string: "https://test.com/\(i).jpg")!
                try? self.cacheService.cacheImage(self.testImage, for: url)
                _ = self.cacheService.cachedImage(for: url)
                group.leave()
            }
        }
        group.wait()
        
    }

    func testCacheEviction() {
        cacheService.cacheCountLimit = 1
        
        let url1 = URL(string: "https://test.com/1.jpg")!
        let url2 = URL(string: "https://test.com/2.jpg")!
        
        try? cacheService.cacheImage(testImage, for: url1)
        try? cacheService.cacheImage(testImage, for: url2)
        
        
        XCTAssertNotNil(cacheService.cachedImage(for: url2))
    }

}
