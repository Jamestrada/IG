//
//  NotificationCellViewModels.swift
//  IG
//
//  Created by James Estrada on 6/21/21.
//

import Foundation

struct FollowNotificationCellViewModel: Equatable {
    let username: String
    let profilePictureUrl: URL
    let isCurrentUserFollowing: Bool
    let date: String
}
