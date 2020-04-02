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
    
    private init(user: User) {
        self.uid = user.uid
        self.fullname = user.displayName ?? ""
        self.profilePictureURL = user.photoURL
    }
    
    init(id: String, value: [String: Any]) {
        self.uid = id
        self.fullname = value["full_name"] as? String ?? ""
        if let profilePictureURLString = value["profile_picture"] as? String {
            self.profilePictureURL = URL.init(string: profilePictureURLString)
        }
    }
    
    convenience init(dictionary: [String: Any]) {
        let uid = dictionary["uid"] as? String ?? ""
        self.init(id: uid, value: dictionary)
    }
    
    static func currentUser() -> SSUser {
        return SSUser(user: Auth.auth().currentUser!)
    }
    
    func author() -> [String: Any] {
        return ["uid": self.uid,
                "full_name": self.fullname,
                "profile_picture": self.profilePictureURL?.absoluteString ?? NSNull()]
    }
}
