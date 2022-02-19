//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Perfect Aduh on 17/02/2022.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnExpectedLavuesRepresentationError: Error { }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            } else {
                completion(.failure(UnExpectedLavuesRepresentationError()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGetFromURLWithRequest() {
                
        let exp = XCTestExpectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequests { [weak self] request in
            XCTAssertEqual(request.url, self?.anyUrl())
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().get(from: anyUrl()) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsonRequestErrorp() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: nil))
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        let requestError = anyError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        XCTAssertEqual((receivedError as? NSError)?.domain, requestError.domain)
        XCTAssertEqual((receivedError as? NSError)?.code, requestError.code)
    }
    
    func test_getFromUrl_successOnHTTPURLResponseWithData() {
        
        let response =  anyHTTPResponse()
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        let emptyData = Data()

        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.reponse.url, response.url)
        XCTAssertEqual(receivedValues?.reponse.statusCode, response.statusCode)
    }
    
    func test_getFromUrl_successWithEmptyDataOnHTTPURLResponseWithNilData() {
        let data = anyData()
        let response =  anyHTTPResponse()

        let receivedValues = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.reponse.url, response.url)
        XCTAssertEqual(receivedValues?.reponse.statusCode, response.statusCode)
    }
    
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        
        trackForMemoryLeak(sut, file: file, line: line)
        
        return sut
    }
    
    private func resultValuesFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, reponse: HTTPURLResponse)? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    
    private func resultFor(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClientResult!
        
        sut.get(from: anyUrl()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
    
    private func anyUrl() -> URL {
        let url = URL(string: "any-url")!
        return url
    }
    
    private func anyData() -> Data {
        Data("any-data".utf8)
    }
    
    private func nonHTTPResponse() -> URLResponse {
        URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPResponse() -> HTTPURLResponse {
        HTTPURLResponse(url: anyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyError() -> NSError {
        NSError(domain: "any-error", code: 0, userInfo: nil)
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let error: Error?
            let data: Data?
            let response: URLResponse?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(error: error, data: data, response: response)
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
