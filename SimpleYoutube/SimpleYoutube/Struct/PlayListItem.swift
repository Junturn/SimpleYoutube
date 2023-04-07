//
//  PlayListItem.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/29.
//

import Foundation

struct PlayList: Codable {
    let nextPageToken: String
    let items:[Item]
}

struct Item: Codable {
    let snippet: Snippet

}

struct Snippet: Codable {
    let title: String
    let thumbnails: Thumbnails
    let resourceId: Resource
    let publishedAt: String
    let videoOwnerChannelTitle: String
}

struct Thumbnails: Codable {
    let standard: ThumStandard
}

struct ThumStandard: Codable {
    let url: String
}

struct Resource: Codable {
    let videoId: String
}
