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
    
    func getPost(of id: String, completion: @escaping (SSPost?) -> Void) {
        postsReference.child(id).observeSingleEvent(of: .value) { (snapshot) in
            let post = SSPost.init(snapshot: snapshot)
            completion(post)
        }
    }
    
    func deletePost(of id: String, completion: @escaping (_ error: Error?) -> Void) {
        postsReference.child(id).observeSingleEvent(of: .value) { (snapshot) in
            guard let post = SSPost.init(snapshot: snapshot) else {
                completion(nil)
                return
            }
            
            let postID = post.postID
            let userID = post.author!.uid
            let restaurantID = post.restaurant!.restaurantID
            let foodID = post.food!.foodID
            let rating = post.rating
            
            // remove associated values
            let update = [ "people/\(userID)/posts/\(postID)": NSNull(),
                           "comments/\(postID)": NSNull(),
                           "likes/\(postID)": NSNull(),
                           "posts/\(postID)": NSNull()]
            SavorData.FireBase.rootReference.updateChildValues(update)
            
            // remove associated values from geo_posts and geo_feed
            let key = CompoundKey.init(post: post).key
            APIs.GeoPosts.geoFire.removeKey(key)
            APIs.GeoFeed.geoFire(ofUser: userID).removeKey(key)
            
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
