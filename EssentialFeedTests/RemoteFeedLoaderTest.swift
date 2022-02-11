//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Perfect Aduh on 11/02/2022.
//

class RemoteFeedLoader {
    
    func load() {
        HTTPClient.shared.requestedUrl = URL(string: "a-url")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    var requestedUrl: URL?
    
    private init() {}
}

import XCTest

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromUrl() {
        let _ = RemoteFeedLoader()
        let client = HTTPClient.shared
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromUrl() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
}
