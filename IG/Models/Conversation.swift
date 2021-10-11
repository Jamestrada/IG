//
//  Conversation.swift
//  IG
//
//  Created by James Estrada on 10/11/21.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let targetUser: User
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let message: String
    let isRead: Bool
}
