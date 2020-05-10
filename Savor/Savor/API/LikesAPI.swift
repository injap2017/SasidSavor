//
//  LikesAPI.swift
//  Savor
//
//  Created by Edgar Sia on 5/6/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class LikesAPI {
    var likesReference = Database.database().reference().child("likes")
    
    func observeLikesPost(_ postID: String, completion: @escaping ([SSLike]) -> Void) -> UInt {
        let likesPostReference = likesReference.child(postID)
        let handler = likesPostReference.observe(.value) { (snapshot) in
            var likes: [SSLike] = []
            for child in snapshot.children {
                let snapshot = child as! DataSnapshot
                let like = SSLike.init(snapshot: snapshot)
                likes.append(like)
            }
            completion(likes)
        }
        return handler
    }
    
    func liked(postID: String, timestamp: Double) {
        let likeReference = likesReference.child(postID).childByAutoId()
        
        let data = ["author": SSUser.currentUser().author(),
                    "timestamp": timestamp] as [String: Any]
        
        likeReference.setValue(data)
    }
    
    func unliked(postID: String, likeID: String) {
        let likeReference = likesReference.child(postID).child(likeID)
        
        likeReference.removeValue()
    }
}
