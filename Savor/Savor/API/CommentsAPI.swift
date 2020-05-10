//
//  CommentsAPI.swift
//  Savor
//
//  Created by Edgar Sia on 5/6/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class CommentsAPI {
    var commentsReference = Database.database().reference().child("comments")
    
    func observeCommentsPost(_ postID: String, completion: @escaping ([SSComment]) -> Void) -> UInt {
        let commentsPostReference = commentsReference.child(postID)
        let handler = commentsPostReference.observe(.value) { (snapshot) in
            var comments: [SSComment] = []
            for child in snapshot.children {
                let snapshot = child as! DataSnapshot
                let comment = SSComment.init(snapshot: snapshot)
                comments.append(comment)
            }
            completion(comments)
        }
        return handler
    }
    
    func commented(postID: String, text: String, timestamp: Double) {
        let commentReference = commentsReference.child(postID).childByAutoId()
        
        let data = ["text": text,
                    "author": SSUser.currentUser().author(),
                    "timestamp": timestamp] as [String: Any]
        
        commentReference.setValue(data)
    }
    
    func uncommented(postID: String, commentID: String) {
        let commentReference = commentsReference.child(postID).child(commentID)
        
        commentReference.removeValue()
    }
}
