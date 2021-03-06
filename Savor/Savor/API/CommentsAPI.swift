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
    
    func observeCommentCount(of id: String, completion: @escaping (Int) -> Void) -> UInt {
        let commentCountHandle = commentsReference.child(id).child("comment_count").observe(.value) { (snapshot) in
            let commentCount = snapshot.value as? Int ?? 0
            completion(commentCount)
        }
        print("comments count observe:\(commentCountHandle), post:\(id)")
        return commentCountHandle
    }
    
    func removeCommentCountObserver(of id: String, withHandle handle: UInt) {
        print("comments remove count observer:\(handle), post:\(id)")
        commentsReference.child(id).child("comment_count").removeObserver(withHandle: handle)
    }
    
    func setCommentCount(of id: String, to commentCount: Int) {
        commentsReference.child(id).child("comment_count").setValue(commentCount)
    }
    
    func commented(postID: String, text: String, timestamp: Double) -> String {
        let commentID = APIs.CommentCollection.commented(text: text, timestamp: timestamp)
        
        let userID = SSUser.authCurrentUser.uid
        let commentReference = commentsReference.child(postID).child("comments").child(userID).child(commentID)
        
        commentReference.setValue(timestamp)
        
        return commentID
    }
    
    func uncommented(postID: String, commentID: String) {
        APIs.CommentCollection.uncommented(commentID: commentID)
        
        let userID = SSUser.authCurrentUser.uid
        let commentReference = commentsReference.child(postID).child("comments").child(userID).child(commentID)
        
        commentReference.removeValue()
    }
    
    func getComments(ofPost postID: String, completion: @escaping ([(String, String, Double)]) -> Void) {
        let commentsPostReference = commentsReference.child(postID).child("comments")
        
        commentsPostReference.observeSingleEvent(of: .value) { (snapshot) in
            let commentsUsers = snapshot.children.allObjects as! [DataSnapshot]
            
            var results: [(String, String, Double)] = []
            
            for commentsUser in commentsUsers {
                let userID = commentsUser.key
                let comments = commentsUser.children.allObjects as! [DataSnapshot]
                for comment in comments {
                    let commentID = comment.key
                    let timestamp = comment.value as? Double ?? 0
                    results.append((userID, commentID, timestamp))
                }
            }
            
            completion(results)
        }
    }
}
