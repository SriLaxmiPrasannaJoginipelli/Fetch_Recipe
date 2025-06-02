//
//  ImageLoaderTests.swift
//  FetchRecipesTests
//
//  Created by Srilu Rao on 6/2/25.
//

import XCTest
@testable import FetchRecipes
@MainActor
final class ImageLoaderTests: XCTestCase {
    let testURL = URL(string: "https://example.com/test-image.png")!
    let cache = ImageCacheService.shared

    override func setUp() async throws {
        URLProtocolMock.reset()
        try? cache.removeImage(for: testURL)
    }

    func makeMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: config)
    }

    func testNetworkFetchHappensWhenCacheMiss() async throws {
        let mockSession = makeMockSession()

        URLProtocolMock.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, makeValidImageData())
        }

        let loader =  ImageLoader(url: testURL, urlSession: mockSession)
        await loader.loadImage()

        XCTAssertEqual(URLProtocolMock.requestCount, 1, "Network should be called when cache misses")
        XCTAssertNotNil(loader.image)
    }

    func testNetworkFetchSkippedWhenCacheHit() async throws {
        let mockSession = makeMockSession()

        // Prime the cache
        let image = UIImage(data: makeValidImageData())!
        try cache.cacheImage(image, for: testURL)

        URLProtocolMock.requestHandler = { request in
            XCTFail("Network call should not happen when image is cached")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, makeValidImageData())
        }

        let loader =  ImageLoader(url: testURL, urlSession: mockSession)
        await loader.loadImage()

        XCTAssertEqual(URLProtocolMock.requestCount, 0, "Network should be skipped when cache hits")
        XCTAssertNotNil(loader.image)
    }
}
