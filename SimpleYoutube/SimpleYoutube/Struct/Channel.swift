//
//  Channel.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/30.
//

import Foundation

struct ChannelInfo : Codable {
    let items:[ChannelItems]
}

struct ChannelItems: Codable {
    let snippet: ChannelSnippet
}

struct ChannelSnippet: Codable {
    let thumbnails: ChannelThumbnails
}

struct ChannelThumbnails: Codable {
    let medium: Medium
}

struct Medium: Codable {
    let url: String
}
