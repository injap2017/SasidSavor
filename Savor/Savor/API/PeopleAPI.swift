//
//  PeopleAPI.swift
//  Savor
//
//  Created by Edgar Sia on 5/12/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class PeopleAPI {
    var peopleReference = Database.database().reference().child("people")
    
    func removeObserver(withHandle handle: UInt) {
        peopleReference.removeObserver(withHandle: handle)
    }
    
    func observeLiked(ofPost postID: String, fromUser userID: String, completion: @escaping (Bool) -> Void) -> UInt {
        let likedHandle = peopleReference.child(userID).child("likes").child(postID).observe(.value) { (snapshot) in
            let liked = snapshot.value as? Bool ?? false
            completion(liked)
        }
        return likedHandle
    }
    
    func Liked(postID: String) {
        let userID = SSUser.currentUser().uid
        peopleReference.child(userID).child("likes").child(postID).setValue(true)
    }
    
    func unliked(postID: String) {
        let userID = SSUser.currentUser().uid
        peopleReference.child(userID).child("likes").child(postID).removeValue()
    }
    
    func observeCommented(ofPost postID: String, fromUser userID: String, completion: @escaping (Bool) -> Void) -> UInt {
        let commentedHandle = peopleReference.child(userID).child("comments").child(postID).observe(.value) { (snapshot) in
            let commented = snapshot.childrenCount > 0
            completion(commented)
        }
        return commentedHandle
    }
    
    func commented(postID: String, commentID: String) {
        let userID = SSUser.currentUser().uid
        peopleReference.child(userID).child("comments").child(postID).child(commentID).setValue(true)
    }
    
    func uncommented(postID: String, commentID: String) {
        let userID = SSUser.currentUser().uid
        peopleReference.child(userID).child("comments").child(postID).child(commentID).removeValue()
    }
}
