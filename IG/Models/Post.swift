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
    let postUrlString: String
    var likers: [String]
    
    var storageReference: String? {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }
        return "\(username)/posts/\(id).png"
    }
}
