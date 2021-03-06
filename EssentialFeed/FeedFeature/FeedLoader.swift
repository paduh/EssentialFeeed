//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Perfect Aduh on 11/02/2022.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
