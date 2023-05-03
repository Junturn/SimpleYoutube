//
//  Comment.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/30.
//

import Foundation

struct Comment: Codable {
    let nextPageToken: String?
    let items: [ItemComment]
}

struct ItemComment: Codable {
    let snippet: SnippetComment
//    let replies: Replies
}

struct SnippetComment: Codable {
    let topLevelComment: TopLevelComment
}

struct TopLevelComment: Codable {
    let snippet: SnippetTLC
}

struct SnippetTLC: Codable {
    let textDisplay: String
    let authorDisplayName: String
    let authorProfileImageUrl: String
    let publishedAt: String
}


//---- 留言的回覆
struct Replies: Codable {
    let comments:[Comments]
}

struct Comments: Codable {
    let snippet: SnippetComments
}

struct SnippetComments: Codable {
    let textDisplay: String
    let authorDisplayName: String
    let authorProfileImageUrl: String
    let publishedAt: String
}
