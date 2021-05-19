//
//  AuthManager.swift
//  IG
//
//  Created by James Estrada on 5/8/21.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    let auth = Auth.auth()
    
    public var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    public func signUp(username: String, email: String, password: String, profilePicture: Data?, completion: @escaping(Result<User, Error>) -> Void) {
        let newUser = User(username: username, email: email)
        
        // Create account
        auth.createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                return
            }
            DatabaseManager.shared.createUser(newUser: newUser) { success in
                
            }
        }
    }
}
