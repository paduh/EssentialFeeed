//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Perfect Aduh on 17/02/2022.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTest: XCTestCase {

    func test_getFromURL_createDataTaskWIthURL() {
        let url = URL(string: "any-url")!
        let session = URLSessionSPY()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        XCTAssertEqual(session.receivedUrls, [url])
    }
    
    // MARK: Helpers

    private class URLSessionSPY: URLSession {
        var receivedUrls = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask { }
}
