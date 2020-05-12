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
    
    func removeObserver(withHandle handle: UInt) {
        likesReference.removeObserver(withHandle: handle)
    }
    
    func observeLikeCount(of id: String, completion: @escaping (Int) -> Void) -> UInt {
        let likeCountHandle = likesReference.child(id).child("like_count").observe(.value) { (snapshot) in
            let likeCount = snapshot.value as? Int ?? 0
            completion(likeCount)
        }
        return likeCountHandle
    }
    
    func setLikeCount(of id: String, to likeCount: Int) {
        likesReference.child(id).child("like_count").setValue(likeCount)
    }
    
    func Liked(postID: String, timestamp: Double) {
        let userID = SSUser.currentUser().uid
        let likeReference = likesReference.child(postID).child("likes").child(userID)
        
        likeReference.setValue(timestamp)
    }
    
    func unliked(postID: String) {
        let userID = SSUser.currentUser().uid
        let likeReference = likesReference.child(postID).child("likes").child(userID)
        
        likeReference.removeValue()
    }
}
