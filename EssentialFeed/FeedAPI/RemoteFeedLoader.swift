//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Perfect Aduh on 11/02/2022.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping(Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url, completion: { error, reponse in
            if reponse != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
        })
    }
}
