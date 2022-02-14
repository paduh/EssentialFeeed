//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Perfect Aduh on 11/02/2022.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
