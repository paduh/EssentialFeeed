//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedTests
//
//  Created by Perfect Aduh on 11/02/2022.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTest: XCTestCase {

    func test_init_doesNotRequestDataFromUrl() {
        let url = URL(string: "any-url.com")!
        let (_, client) = makeSUT(url: url)
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in}
        
        XCTAssertEqual([url], client.requestedUrls)
    }
    
    func test_loadTwice_requestsDataFromUrlTwice() {
        let url = URL(string: "any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in}
        sut.load { _ in}
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 000, userInfo: nil)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 404, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                client.complete(withStatusCode: code, index: index)
            }
        }
    }
    
    func test_load_deliversNoItemOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSON)
        }
    }
    
    func test_load_deliversErrorsOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    // MARK: Helpers
    
    private func  makeSUT(url: URL = URL(string: "any-url.com")!) -> (RemoteFeedLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResult = [RemoteFeedLoader.Result]()
        sut.load { capturedResult.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResult, [result], file: file, line: line)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completions: (HTTPClientResult) -> Void)]()
        var requestedUrls: [URL] {
            messages.map { $0.url}
        }
        
        func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completions(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedUrls[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completions(.success(data, response))
        }
    }
}
