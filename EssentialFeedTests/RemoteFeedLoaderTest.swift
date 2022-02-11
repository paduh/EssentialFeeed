//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Perfect Aduh on 11/02/2022.
//

class RemoteFeedLoader {
    
    func load() {
        HTTPClient.shared.get(from: URL(string: "a-url")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
        
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    
    var requestedUrl: URL?
    
    override func get(from url: URL) {
        requestedUrl = url
    }
}

import XCTest

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromUrl() {
        let _ = RemoteFeedLoader()
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromUrl() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
}
