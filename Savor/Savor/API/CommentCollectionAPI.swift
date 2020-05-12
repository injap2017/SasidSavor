//
//  CommentCollectionAPI.swift
//  Savor
//
//  Created by Edgar Sia on 5/12/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class CommentCollectionAPI {
    var commentCollectionReference = Database.database().reference().child("comment_collection")
    
    func commented(text: String, timestamp: Double) -> String {
        let commentReference = commentCollectionReference.childByAutoId()
        let data = ["text": text,
                    "timestamp": timestamp] as [String: Any]
        commentReference.setValue(data)
        
        return commentReference.key!
    }
    
    func uncommented(commentID: String) {
        let commentReference = commentCollectionReference.child(commentID)
        commentReference.removeValue()
    }
}
