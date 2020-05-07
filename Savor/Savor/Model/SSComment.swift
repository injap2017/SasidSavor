//
//  SSComment.swift
//  Savor
//
//  Created by Edgar Sia on 5/6/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class SSComment {
    var commentID: String
    var text: String
    var author: SSUser?
    var timestamp: Double
    
    convenience init(snapshot: DataSnapshot) {
        let commentID = snapshot.key
        let value = snapshot.value as! [String: Any]
        self.init(id: commentID, value: value)
    }
    
    init(id: String, value: [String: Any]) {
        self.commentID = id
        self.text = value["text"] as? String ?? ""
        if let author = value["author"] as? [String: Any] {
            self.author = SSUser.init(dictionary: author)
        }
        self.timestamp = value["timestamp"] as? Double ?? 0.0
    }
}
