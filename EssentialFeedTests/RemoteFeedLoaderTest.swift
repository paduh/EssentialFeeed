//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Perfect Aduh on 11/02/2022.
//

class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    
    var requestedUrl: URL?
    
    func get(from url: URL) {
        requestedUrl = url
    }
}

import XCTest

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromUrl() {
        let client = HTTPClientSpy()
        let url = URL(string: "any-url.com")!
        let _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromUrl() {
        let client = HTTPClientSpy()
        let url = URL(string: "any-url.com")!
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(url, client.requestedUrl)
    }
}
