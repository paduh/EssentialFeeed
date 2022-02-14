//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Perfect Aduh on 15/02/2022.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void)
}
