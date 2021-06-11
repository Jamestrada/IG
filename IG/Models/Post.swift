//
//  Post.swift
//  IG
//
//  Created by James Estrada on 6/10/21.
//

import Foundation

struct Post: Codable {
    let id: String
    let caption: String
    let postedDate: String
    var likers: [String]
}
