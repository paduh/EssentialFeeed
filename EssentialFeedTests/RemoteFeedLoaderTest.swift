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

import XCTest

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromUrl() {
        let url = URL(string: "any-url.com")!
        let (_, client) = makeSUT(url: url)
        
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromUrl() {
        let url = URL(string: "any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(url, client.requestedUrl)
    }
    
    // MARK: Helpers
    
    private func  makeSUT(url: URL = URL(string: "any-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedUrl: URL?
        
        func get(from url: URL) {
            requestedUrl = url
        }
    }
}
