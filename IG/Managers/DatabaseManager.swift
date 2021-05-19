//
//  DatabaseManager.swift
//  IG
//
//  Created by James Estrada on 5/8/21.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        let reference = database.document("users/\(newUser.username)")
        
    }
}
