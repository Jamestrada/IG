//
//  StorageManager.swift
//  IG
//
//  Created by James Estrada on 5/8/21.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    static let shared = StorageManager()
    
    private init() {}
    
    private let storage = Storage.storage().reference()
    
    /// Upload post's image
        /// - Parameters:
        ///   - data: Image data
        ///   - id: New post id
        ///   - completion: Result callback
    public func uploadPost(data: Data?, id: String, completion: @escaping (URL?) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username"), let data = data else {
            return
        }
        let ref = storage.child("\(username)/posts/\(id).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    public func downloadURL(for post: Post, completion: @escaping (URL?) -> Void) {
        guard let ref = post.storageReference else {
            completion(nil)
            return
        }
        
        storage.child(ref).downloadURL { url, _ in
            completion(url)
        }
    }
    
    public func profilePictureURL(for username: String, completion: @escaping (URL?) -> Void) {
        storage.child("\(username)/profile_picture.png").downloadURL { url, _ in
            completion(url)
        }
    }
    
    /// Uploads profile picture to firebase storage
    public func uploadProfilePicture(username: String, data: Data?, completion: @escaping (Bool) -> Void) {
        guard let data = data else {
            completion(false)
            return
        }
        storage.child("\(username)/profile_picture.png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
    
    /// Uploads image that will be sent in a conversation message
    public func uploadMessagePhoto(username: String, data: Data?, fileName: String, completion: @escaping (Bool) -> Void) {
        guard let data = data else {
            completion(false)
            return
        }
        storage.child("\(username)/message_images/\(fileName)").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
    
    /// Uploads video that will be sent in a conversation message
    public func uploadMessageVideo(username: String, fileUrl: URL, fileName: String, completion: @escaping (Bool) -> Void) {
        storage.child("\(username)/message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
}
