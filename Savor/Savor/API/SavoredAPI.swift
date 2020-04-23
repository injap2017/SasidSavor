//
//  SavoredAPI.swift
//  Savor
//
//  Created by Edgar Sia on 4/23/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class SavoredAPI {
    var savoredReference = Database.database().reference().child("savored")
    
    func savored(foodID: String, restaurantID: String, postID: String, rating: Double, completion: @escaping (_ error: Error?) -> Void) {
        let savoredFoodReference = savoredReference.child(restaurantID).child(foodID)
        savoredFoodReference.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var savoredfood = currentData.value as? [String: AnyObject] {
                
                var posts: Dictionary<String, Bool>
                posts = savoredfood["posts"] as? [String: Bool] ?? [:]
                var totalRating = savoredfood["total_rating"] as? Double ?? 0
                
                totalRating += rating
                posts[postID] = true
                
                savoredfood["posts"] = posts as AnyObject?
                savoredfood["total_rating"] = totalRating as AnyObject?
                
                currentData.value = savoredfood
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            completion(error)
        }
    }
    
    func getPostsSavoredFood(_ foodID: String, in restaurantID: String, completion: @escaping (_ posts: [String], _ totalRating: Double) -> Void) {
        let savoredFoodReference = savoredReference.child(restaurantID).child(foodID)
        savoredFoodReference.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String: Any],
                let posts = value["posts"] as? [String: Bool],
                let totalRating = value["total_rating"] as? Double {
                var postIDs: [String] = []
                for post in posts {
                    postIDs.append(post.key)
                }
                completion(postIDs, totalRating)
                return
            }
            completion([], 0)
        }
    }
}

