//
//  DatabaseManager.swift
//  IG
//
//  Created by James Estrada on 5/8/21.
//

import Foundation
import FirebaseFirestore
import MessageKit

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    
    public func findUsers(with usernamePrefix: String, completion: @escaping ([User]) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion([])
                return
            }
            let subset = users.filter({
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            })
            completion(subset)
        }
    }
    
    public func posts(for username: String, completion: @escaping (Result<[Post], Error>) -> Void) {
        let ref = database.collection("users").document(username).collection("posts")
        ref.getDocuments { snapshot, error in
            guard let posts = snapshot?.documents.compactMap({Post(with: $0.data())}).sorted(by: {
                return $0.date > $1.date
            }), error == nil else {
                return
            }
            completion(.success(posts))
        }
    }
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.email == email })
            completion(user)
        }
    }
    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func findUser(username: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.username == username })
            completion(user)
        }
    }
    
    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let reference = database.document("users/\(username)/posts/\(newPost.id)")
        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func explorePosts(completion: @escaping ([(post: Post, user: User)]) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }), error == nil else {
                completion([])
                return
            }
            
            let group = DispatchGroup()
            var aggregatePosts = [(post: Post, user: User)]()
            
            users.forEach { user in
                group.enter()
                
                let username = user.username
                let postsRef = self.database.collection("users/\(username)/posts")
                
                postsRef.getDocuments { snapshot, error in
                    defer {
                        group.leave()
                    }
                    
                    guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data()) }), error == nil else {
                        return
                    }
                    aggregatePosts.append(contentsOf: posts.compactMap({ (post: $0, user: user)}))
                }
            }
            group.notify(queue: .main) {
                completion(aggregatePosts)
            }
        }
    }
    
    public func getNotifications(completion: @escaping ([IGNotification]) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion([])
            return
        }
        let ref = database.collection("users").document(username).collection("notifications")
        ref.getDocuments { snapshot, error in
            guard let notifications = snapshot?.documents.compactMap({ IGNotification(with: $0.data()) }), error == nil else {
                completion([])
                return
            }
            completion(notifications)
        }
    }
    
    public func insertNotification(identifier: String, data: [String: Any], for username: String) {
        let ref = database.collection("users").document(username).collection("notifications").document(identifier)
        ref.setData(data)
    }
    
    public func getPost(with identifier: String, from username: String, completion: @escaping(Post?) -> Void) {
        let ref = database.collection("users").document(username).collection("posts").document(identifier)
        ref.getDocument { snaptshot, error in
            guard let data = snaptshot?.data(), error == nil else {
                completion(nil)
                return
            }
            completion(Post(with: data))
        }
    }
    
    enum RelationshipState {
        case follow
        case unfollow
    }
    
    public func updateRelationship(state: RelationshipState, for targetUsername: String, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let currentFollowing = database.collection("users").document(currentUsername).collection("following")
        let targetFollowers = database.collection("users").document(targetUsername).collection("followers")
        
        switch state {
        case .unfollow:
            // Remove follower from currentUser's following list
            currentFollowing.document(targetUsername).delete()
            // Remove currentUser from targetUser's followers list
            targetFollowers.document(currentUsername).delete()
            
            completion(true)
        case .follow:
            // Add follower to requester's following list
            currentFollowing.document(targetUsername).setData(["valid": "1"])
            // Add currentUser to targetUser's followers list
            targetFollowers.document(currentUsername).setData(["valid": "1"])
        
            completion(true)
        }
    }
    
    public func getUserCounts(username: String, completion: @escaping ((followers: Int, following: Int, posts: Int)) -> Void) {
        let userRef = database.collection("users").document(username)
        var followers = 0
        var following = 0
        var posts = 0
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        userRef.collection("followers").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            followers = count
        }
        
        userRef.collection("following").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            following = count
        }
        
        userRef.collection("posts").getDocuments { snapshot, error in
            defer {
                group.leave()
            }
            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            posts = count
        }
        
        group.notify(queue: .global()) {
            let result = (followers: followers, following: following, posts: posts)
            completion(result)
        }
    }
    
    public func isFollowing(targetUsername: String, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        let ref = database.collection("users").document(targetUsername).collection("followers").document(currentUsername)
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // Following
            completion(true)
        }
    }
    
    public func followers(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users").document(username).collection("followers")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID}), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    /// Gets users that the username follows
    public func following(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users").document(username).collection("following")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID}), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }
    
    // MARK: - User info
    public func getUserInfo(username: String, completion: @escaping (UserInfo?) -> Void) {
        let ref = database.collection("users").document(username).collection("information").document("basic")
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(), let userInfo = UserInfo(with: data) else {
                completion(nil)
                return
            }
            completion(userInfo)
        }
    }
    
    public func setUserInfo(userInfo: UserInfo, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username"), let data = userInfo.asDictionary() else {
            return
        }
        let ref = database.collection("users").document(username).collection("information").document("basic")
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    // MARK: - Comment
    
    public func createComments(comment: Comment, postID: String, owner: String, completion: @escaping (Bool) -> Void) {
        let newIdentifier = "\(postID)_\(comment.username)_\(Date().timeIntervalSince1970)_\(Int.random(in: 0...1000))"
        let ref = database.collection("users").document(owner).collection("posts").document(postID).collection("comments").document(newIdentifier)
        guard let data = comment.asDictionary() else {
            return
        }
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func getComments(postID: String, owner: String, completion: @escaping ([Comment]) -> Void) {
        let ref = database.collection("users").document(owner).collection("posts").document(postID).collection("comments")
        ref.getDocuments { snapshot, error in
            guard let comments = snapshot?.documents.compactMap( { Comment(with: $0.data()) }), error == nil else {
                completion([])
                return
            }
            completion(comments)
        }
    }
    
    // MARK: - Liking
    
    enum LikeState {
        case like, unlike
    }
    
    public func updateLikeState(state: LikeState, postID: String, owner: String, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let ref = database.collection("users").document(owner).collection("posts").document(postID)
        getPost(with: postID, from: owner) { post in
            guard var post = post else {
                completion(false)
                return
            }
            
            switch state {
            case .like:
                if !post.likers.contains(currentUsername) {
                    post.likers.append(currentUsername)
                }
            case .unlike:
                post.likers.removeAll(where: { $0 == currentUsername })
            }
            
            guard let data = post.asDictionary() else {
                completion(false)
                return
            }
            ref.setData(data) { error in
                completion(error == nil)
            }
        }
    }
}

// MARK: - Messaging

extension DatabaseManager {
    
    /*
     
        messages -> "asdfasdf" {
                        "messages": [
                            {
                                "id": String,
                                "type": text, photo, video
                                "content": String
                                "date": Date(),
                                "sender_email": String
                                "isRead": true/false
                            }
                        ]
                    }
     
        user -> conversations -> [
                [
                    "conversation_id": "asdfasdf"
                    "target_user":
                    "latest_message": -> {
                        "date": Date()
                        "latest_message": "message"
                        "is_read": true/false
                    }
                ]
            ]
     
     */
    
    /// Create a  new conversation with target user email and first message sent
    public func createNewConversation(with targetUser: User, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        guard let data = newPost.asDictionary() else {
//            completion(false)
//            return
//        }
//        reference.setData(data) { error in
//            completion(error == nil)
//        }
        guard let currentUsername = UserDefaults.standard.value(forKey: "username") as? String else {
            completion(false)
            return
        }
        print(currentUsername)
        let ref = database.document("users/\(currentUsername)/conversations")
        ref.getDocument { [weak self] snapshot, error in
            guard var userNode = snapshot?.data() else {
                completion(false)
                print("user not found")
                return
            }
            
            print(userNode)
            let messageDate = firstMessage.sentDate
            let dateString = DateFormatter.formatter.string(from: messageDate)
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "target_user": targetUser.username,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "target_user": targetUser.username,
                "name": currentUsername,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            // Update recipient conversation entry
            self?.database.document("users/\(targetUser)/conversations").getDocument { [weak self] snapshot, error in
                if var conversations = snapshot?.data() as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.document("users/\(targetUser)/conversations/\(conversationId)")
                }
                else {
                    // create
                    self?.database.document("users/\(targetUser)/conversations").setData(recipient_newConversationData)
                }
            }
            
            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                // append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setData(userNode) { [weak self] error in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }
            else {
                // conversation array doesn't exist
                // create
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setData(userNode) { [weak self] error in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }
        }
        
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = DateFormatter.formatter.string(from: messageDate)
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "name": name,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read":false
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.document(conversationID).setData(value) { error in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for username: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        let ref = database.collection("users").document(username).collection("conversations")
        ref.getDocuments { snapshot, error in
            guard let value = snapshot?.documents as? [[String: Any]], error == nil else {
                completion(.failure("Failed to fetch" as! Error))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let targetUser = dictionary["target_user"] as? User,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date, message: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, targetUser: targetUser, latestMessage: latestMessageObject)
            }
            completion(.success(conversations))
        }
    }
    
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        let ref = database.collection("users").document(id).collection("messages")
        ref.getDocuments { snapshot, error in
            guard let value = snapshot?.documents as? [[String: Any]], error == nil else {
                completion(.failure("Failed to fetch" as! Error))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String,
                      let date = DateFormatter.formatter.date(from: dateString) else {
                    return nil
                }
                
                var kind: MessageKind?
                if type == "photo" {
                    // photo
                    guard let imageUrl = URL(string: content) else {
                        return nil
                    }
                    kind = .photo(media)
                }
                else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                
                let sender = Sender(senderId: senderEmail, displayName: name, photoURL: "")
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: finalKind)
            }
            completion(.success(messages))
        }
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherUser: User, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // Add new message to messages
        // Update sender latest message
        // Update recipient latest message
        
        guard let currentUser = UserDefaults.standard.value(forKey: "username") as? String else {
            completion(false)
            return
        }
        
        let ref = database.collection("users").document(conversation).collection("messages")
        ref.getDocuments { [weak self] snapshot, error in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot?.documents as? [[String: Any]] else {
                completion(false)
                return
            }
            let messageDate = newMessage.sentDate
            let dateString = DateFormatter.formatter.string(from: messageDate)
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "name": name,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read":false
            ]
            
            let value: [String: Any] = [
                "messages": [
                    currentMessages.append(newMessageEntry)
                ]
            ]
            
            strongSelf.database.document("users/\(conversation)/messages").setData(value) { error in
                guard error == nil else {
                    return
                }
                strongSelf.database.document("users/\(currentUser)/conversations").getDocument { snapshot, error in
                    guard var currentUserConversations = snapshot?.data() as? [[String: Any]], error == nil else {
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                    ]
                    
                    var targetConversation: [String: Any]?
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConversation
                    strongSelf.database.document("users/\(currentUser)/conversations").setData(currentUserConversations as? [String: Any] ?? ["":""]) { error in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        // Update latest message for recipient
                        strongSelf.database.document("users/\(otherUser.username)/conversations").getDocument { snapshot, error in
                            guard var otherUserConversations = snapshot?.data() as? [[String: Any]], error == nil else {
                                return
                            }
                            
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "message": message,
                                "is_read": false
                            ]
                            
                            var targetConversation: [String: Any]?
                            var position = 0
                            
                            for conversationDictionary in otherUserConversations {
                                if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConversation
                            strongSelf.database.document("users/\(otherUser.username)/conversations").setData(otherUserConversations as? [String: Any] ?? ["":""]) { error in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
}
