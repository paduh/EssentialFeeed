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
        session.dataTask(with: url) { _, _, _ in }.resume()
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
    
    func test_getFromURL_resumesDataTaskWIthURL() {
        let url = URL(string: "any-url")!
        let session = URLSessionSPY()
        let task = URLSessionDataTaskSPY()
        
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: Helpers

    private class URLSessionSPY: URLSession {
        var receivedUrls = [URL]()
        var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedUrls.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataTaskSPY: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
