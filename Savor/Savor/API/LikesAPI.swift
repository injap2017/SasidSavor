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
    
    func observeLikeCount(of id: String, completion: @escaping (Int) -> Void) -> UInt {
        let likeCountHandle = likesReference.child(id).child("like_count").observe(.value) { (snapshot) in
            let likeCount = snapshot.value as? Int ?? 0
            completion(likeCount)
        }
        print("likes count observe:\(likeCountHandle), post:\(id)")
        return likeCountHandle
    }
    
    func removeLikeCountObserver(of id: String, withHandle handle: UInt) {
        print("likes remove count observer:\(handle), post:\(id)")
        likesReference.child(id).child("like_count").removeObserver(withHandle: handle)
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
    
    func getLikes(ofPost postID: String, completion: @escaping ([(String, Double)]) -> Void) {
        let likesPostReference = likesReference.child(postID).child("likes")
        
        likesPostReference.observeSingleEvent(of: .value) { (snapshot) in
            let likesUsers = snapshot.children.allObjects as! [DataSnapshot]
            
            var results: [(String, Double)] = []
            
            for likesUser in likesUsers {
                let userID = likesUser.key
                let timestamp = likesUser.value as? Double ?? 0
                results.append((userID, timestamp))
            }
            
            completion(results)
        }
    }
}
