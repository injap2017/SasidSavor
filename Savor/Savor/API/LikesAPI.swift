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
    
    func liked(postID: String, timestamp: Double, completion: @escaping () -> Void) {
        
    }
    
    func unliked(postID: String, likeID: String, completion: @escaping () -> Void) {
        
    }
}
