//
//  MockURLProtocol.swift
//  FetchRecipes
//
//  Created by Srilu Rao on 6/2/25.
//

import Foundation

class MockURLProtocol: URLProtocol {
    static var requestCount = 0
    static var testData: Data?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        Self.requestCount += 1
        
        
        let data = Self.testData ?? Data()
        self.client?.urlProtocol(self, didLoad: data)
        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
