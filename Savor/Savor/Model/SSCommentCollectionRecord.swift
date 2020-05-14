//
//  SSCommentCollectionRecord.swift
//  Savor
//
//  Created by Edgar Sia on 5/14/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class SSCommentCollectionRecord {
    var commentID: String
    var text: String
    var timestamp: Double
    
    convenience init(snapshot: DataSnapshot) {
        let commentID = snapshot.key
        let value = snapshot.value as! [String: Any]
        self.init(id: commentID, value: value)
    }
    
    init(id: String, value: [String: Any]) {
        self.commentID = id
        self.text = value["text"] as? String ?? ""
        self.timestamp = value["timestamp"] as? Double ?? 0.0
    }
}
