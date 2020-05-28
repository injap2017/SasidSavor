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
    
    func observeLiked(ofPost postID: String, fromUser userID: String, completion: @escaping (Bool) -> Void) -> UInt {
        let likedHandle = peopleReference.child(userID).child("likes").child(postID).observe(.value) { (snapshot) in
            let liked = snapshot.value as? Bool ?? false
            completion(liked)
        }
        print("people liked observe:\(likedHandle), post:\(postID), userID:\(userID)")
        return likedHandle
    }
    
    func removeLikedObserver(ofPost postID: String, fromUser userID: String, withHandle handle: UInt) {
        print("people remove liked observer:\(handle), post:\(postID), userID:\(userID)")
        peopleReference.child(userID).child("likes").child(postID).removeObserver(withHandle: handle)
    }
    
    func Liked(postID: String) {
        let userID = SSUser.authCurrentUser.uid
        peopleReference.child(userID).child("likes").child(postID).setValue(true)
    }
    
    func unliked(postID: String) {
        let userID = SSUser.authCurrentUser.uid
        peopleReference.child(userID).child("likes").child(postID).removeValue()
    }
    
    func observeCommented(ofPost postID: String, fromUser userID: String, completion: @escaping (Bool) -> Void) -> UInt {
        let commentedHandle = peopleReference.child(userID).child("comments").child(postID).observe(.value) { (snapshot) in
            let commented = snapshot.childrenCount > 0
            completion(commented)
        }
        print("people commented observe:\(commentedHandle), post:\(postID), userID:\(userID)")
        return commentedHandle
    }
    
    func removeCommentedObserver(ofPost postID: String, fromUser userID: String, withHandle handle: UInt) {
        print("people remove commented observer:\(handle), post:\(postID), userID:\(userID)")
        peopleReference.child(userID).child("comments").child(postID).removeObserver(withHandle: handle)
    }
    
    func commented(postID: String, commentID: String) {
        let userID = SSUser.authCurrentUser.uid
        peopleReference.child(userID).child("comments").child(postID).child(commentID).setValue(true)
    }
    
    func uncommented(postID: String, commentID: String) {
        let userID = SSUser.authCurrentUser.uid
        peopleReference.child(userID).child("comments").child(postID).child(commentID).removeValue()
    }
    
    func getPostCount(ofUser userID: String, completion: @escaping (Int) -> Void) {
        let peoplePostsReference = peopleReference.child(userID).child("posts")
        peoplePostsReference.observeSingleEvent(of: .value) { (snapshot) in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func getFollowingCount(ofUser userID: String, completion: @escaping (Int) -> Void) {
        let peopleFollowingsReference = peopleReference.child(userID).child("followings")
        peopleFollowingsReference.observeSingleEvent(of: .value) { (snapshot) in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func getFollowerCount(ofUser userID: String, completion: @escaping (Int) -> Void) {
        let peopleFollowersReference = peopleReference.child(userID).child("followers")
        peopleFollowersReference.observeSingleEvent(of: .value) { (snapshot) in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func getFollowings(ofUser userID: String, completion: @escaping ([SSUser]) -> Void) {
        let peopleFollowingsReference = peopleReference.child(userID).child("followings")
        peopleFollowingsReference.observeSingleEvent(of: .value) { (snapshot) in
            let followings = snapshot.children.allObjects as! [DataSnapshot]
            
            var results: [SSUser] = []
            
            let dispatchGroup = DispatchGroup()
            for following in followings {
                dispatchGroup.enter()
                APIs.Users.getUser(of: following.key) { (user) in
                    results.append(user)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                results.sort(by: {$0.fullname > $1.fullname})
                completion(results)
            }
        }
    }
    
    func getFollowers(ofUser userID: String, completion: @escaping ([SSUser]) -> Void) {
        let peopleFollowersReference = peopleReference.child(userID).child("followers")
        peopleFollowersReference.observeSingleEvent(of: .value) { (snapshot) in
            let followers = snapshot.children.allObjects as! [DataSnapshot]
            
            var results: [SSUser] = []
            
            let dispatchGroup = DispatchGroup()
            for follower in followers {
                dispatchGroup.enter()
                APIs.Users.getUser(of: follower.key) { (user) in
                    results.append(user)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                results.sort(by: {$0.fullname > $1.fullname})
                completion(results)
            }
        }
    }
    
    func getRecentPosts(ofUser userID: String, start timestamp: Double? = nil, limit: UInt, completionHandler: @escaping ([SSPost]) -> Void) {
        let query = peopleReference.child(userID).child("posts").queryOrderedByValue()
        var startingLimitedQuery: DatabaseQuery
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            startingLimitedQuery = query.queryStarting(atValue: latestPostTimestamp + 1).queryLimited(toLast: limit)
        } else {
            startingLimitedQuery = query.queryLimited(toLast: limit)
        }
        
        startingLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let items = snapshot.children.allObjects as! [DataSnapshot]
            
            var results: [SSPost] = []
            
            let dispatchGroup = DispatchGroup()
            for item in items {
                dispatchGroup.enter()
                APIs.Posts.getPost(of: item.key) { (post) in
                    results.append(post)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                results.sort(by: {$0.timestamp > $1.timestamp})
                completionHandler(results)
            }
        })
    }
    
    func getOldPosts(ofUser userID: String, start timestamp: Double, limit: UInt, completionHandler: @escaping ([SSPost]) -> Void) {
        let query = peopleReference.child(userID).child("posts").queryOrderedByValue()
        let endingLimitedQuery = query.queryEnding(atValue: timestamp - 1).queryLimited(toLast: limit)
        
        endingLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let items = snapshot.children.allObjects as! [DataSnapshot]
         
            var results: [SSPost] = []
            
            let dispatchGroup = DispatchGroup()
            for item in items {
                dispatchGroup.enter()
                APIs.Posts.getPost(of: item.key) { (post) in
                    results.append(post)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                results.sort(by: {$0.timestamp > $1.timestamp })
                completionHandler(results)
            }
        })
    }
}
