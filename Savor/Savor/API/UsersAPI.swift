//
//  UsersAPI.swift
//  Savor
//
//  Created by Edgar Sia on 5/15/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class UsersAPI {
    var usersReference = Database.database().reference().child("users")
    
    func getUser(of id: String, completion: @escaping (SSUser) -> Void) {
        usersReference.child(id).observeSingleEvent(of: .value) { (snapshot) in
            let user = SSUser.init(snapshot: snapshot)
            completion(user)
        }
    }
    
    func setUser(_ user: SSUser) {
        self.setUser(of: user.uid, withValue: user.value())
    }
    
    func setUser(of id: String, withValue value: [String: Any]) {
        let userReference = usersReference.child(id)
        userReference.setValue(value)
    }
}
