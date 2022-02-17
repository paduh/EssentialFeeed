//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Perfect Aduh on 17/02/2022.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromURL_failsonRequestErrorp() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "any-url")!
        let error = NSError(domain: "any error", code: 1)
        
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result{
            case let .failure(recievedError as NSError):
                XCTAssertEqual(recievedError.domain, error.domain)
                XCTAssertEqual(recievedError.code, error.code)
            default:
                XCTFail("Expected failure with \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequest()
    }
    
    // MARK: Helpers
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: HTTPURLResponse?
        }
        
        static func stub(url: URL, data: Data?, response: HTTPURLResponse?, error: Error? = nil) {
            stubs[url] = Stub(error: error, data: data, response: response)
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
