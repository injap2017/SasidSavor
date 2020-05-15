//
//  SSUser.swift
//  Savor
//
//  Created by Edgar Sia on 3/30/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class SSUser {
    var uid: String
    var fullname: String
    var profilePictureURL: URL?
    var firstName: String
    var lastName: String
    
    init(authUser user: User) {
        self.uid = user.uid
        self.fullname = user.displayName ?? ""
        self.profilePictureURL = user.photoURL
        self.firstName = ""
        self.lastName = ""
    }
    
    init(id: String, value: [String: Any]) {
        self.uid = id
        self.fullname = value["full_name"] as? String ?? ""
        if let profilePictureURLString = value["profile_picture"] as? String {
            self.profilePictureURL = URL.init(string: profilePictureURLString)
        }
        self.firstName = value["first_name"] as? String ?? ""
        self.lastName = value["last_name"] as? String ?? ""
    }
    
    convenience init(snapshot: DataSnapshot) {
        let uid = snapshot.key
        let value = snapshot.value as! [String: Any]
        self.init(id: uid, value: value)
    }
    
    convenience init(dictionary: [String: Any]) {
        let uid = dictionary["uid"] as? String ?? ""
        self.init(id: uid, value: dictionary)
    }
    
    func author() -> [String: Any] {
        return ["uid": self.uid,
                "full_name": self.fullname,
                "profile_picture": self.profilePictureURL?.absoluteString ?? NSNull()]
    }
    
    func value() -> [String: Any] {
        return ["full_name": self.fullname,
                "profile_picture": self.profilePictureURL?.absoluteString ?? NSNull(),
                "first_name": self.firstName,
                "last_name": self.lastName]
    }
}

// MARK: - Authentication
extension SSUser {
    static var authCurrentUser: SSUser {
        get {
            return SSUser(authUser: Auth.auth().currentUser!)
        }
    }
    static var isAuthenticated: Bool {
        get {
            return Auth.auth().currentUser != nil
        }
    }
}
