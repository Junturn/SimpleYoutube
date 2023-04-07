//
//  VideoDes.swift
//  SimpleYoutube
//
//  Created by Junteng on 2023/3/30.
//

import Foundation

struct Description: Codable {
    let items:[Items]
}

struct Items: Codable {
    let snippet: Snippets
}

struct Snippets: Codable {
    let description: String
}
