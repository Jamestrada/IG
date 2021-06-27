//
//  NotificationsManager.swift
//  IG
//
//  Created by James Estrada on 6/20/21.
//

import Foundation

final class NotificationsManager {
    static let shared = NotificationsManager()
    
    enum IGType: Int {
        case like = 1
        case comment = 2
        case follow = 3
    }
    
    private init() {}
    
    public func getNotifications(completion: @escaping ([IGNotification]) -> Void) {
        DatabaseManager.shared.getNotifications(completion: completion)
    }
    
    static func newIdentifier() -> String {
        let date = Date()
        let number1 = Int.random(in: 0...1000)
        let number2 = Int.random(in: 0...1000)
        return "\(number1)_\(number2)_\(date.timeIntervalSince1970)"
    }
    
    public func create(notification: IGNotification, for username: String) {
        let id = notification.identifier
        guard let dictionary = notification.asDictionary() else {
            return
        }
        DatabaseManager.shared.insertNotification(identifier: id, data: dictionary, for: username)
    }
}
