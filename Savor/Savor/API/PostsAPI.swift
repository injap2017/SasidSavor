//
//  PostAPI.swift
//  Savor
//
//  Created by Edgar Sia on 4/1/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class PostsAPI {
    var postsReference = Database.database().reference().child("posts")
    
    func getPost(of id: String, completion: @escaping (SSPost) -> Void) {
        postsReference.child(id).observeSingleEvent(of: .value) { (snapshot) in
            let post = SSPost.init(snapshot: snapshot)
            completion(post)
        }
    }
    
    func getRecentPosts(start timestamp: Double? = nil, limit: UInt, completionHandler: @escaping ([SSPost]) -> Void) {
        let query = postsReference.queryOrdered(byChild: "timestamp")
        var startingLimitedQuery: DatabaseQuery
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            startingLimitedQuery = query.queryStarting(atValue: latestPostTimestamp + 1, childKey: "timestamp").queryLimited(toLast: limit)
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
    
    func getOldPosts(start timestamp: Double, limit: UInt, completionHandler: @escaping ([SSPost]) -> Void) {
        let query = postsReference.queryOrdered(byChild: "timestamp")
        let endingLimitedQuery = query.queryEnding(atValue: timestamp - 1, childKey: "timestamp").queryLimited(toLast: limit)
        
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
    
    func listenNewPostAdded(with block: @escaping (SSPost) -> Void) {
        postsReference.observe(.childAdded) { (snapshot) in
            block(SSPost.init(snapshot: snapshot))
        }
    }
    
    func deletePost(of id: String, completion: @escaping (_ error: Error?) -> Void) {
        postsReference.child(id).observeSingleEvent(of: .value) { (snapshot) in
            let post = SSPost.init(snapshot: snapshot)
            let postID = post.postID
            let userID = post.author!.uid
            let restaurantID = post.restaurant!.restaurantID
            let foodID = post.food!.foodID
            let rating = post.rating
            
            // remove associated values
            let update = [ "people/\(userID)/posts/\(postID)": NSNull(),
                           "comments/\(postID)": NSNull(),
                           "likes/\(postID)": NSNull(),
                           "posts/\(postID)": NSNull(),
                           "feed/\(userID)/\(postID)": NSNull()]
            SavorData.FireBase.rootReference.updateChildValues(update)
            
            // remove photos from storage
            let storage = Storage.storage()
            if let photos = post.photos {
                for photo in photos {
                    if let fullStorageURI = photo["full_storage_uri"] {
                        storage.reference(withPath: fullStorageURI).delete()
                    }
                }
            }
            
            // unsavored
            APIs.Savored.unsavored(foodID: foodID, in: restaurantID, postID: postID, rating: rating) { (error) in
                completion(error)
            }
        }
    }
}
