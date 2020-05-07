//
//  SSLike.swift
//  Savor
//
//  Created by Edgar Sia on 5/6/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class SSLike {
    var likeID: String
    var author: SSUser?
    var timestamp: Double
    
    convenience init(snapshot: DataSnapshot) {
        let likeID = snapshot.key
        let value = snapshot.value as! [String: Any]
        self.init(id: likeID, value: value)
    }
    
    init(id: String, value: [String: Any]) {
        self.likeID = id
        if let author = value["author"] as? [String: Any] {
            self.author = SSUser.init(dictionary: author)
        }
        self.timestamp = value["timestamp"] as? Double ?? 0.0
    }
}
