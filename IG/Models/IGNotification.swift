//
//  Notification.swift
//  IG
//
//  Created by James Estrada on 6/24/21.
//

import Foundation

struct IGNotification: Codable {
    let notificationType: Int // 1: like, 2: comment, 3: follow
    let profilePictureUrl: String
    let username: String
    
    // Follow/Unfollow
    let isFollowing: Bool?
    
    // Like/Comment
    let postId: String?
    let postUrl: String?
}
