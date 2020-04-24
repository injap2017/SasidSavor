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
    
    func savored(foodID: String, in restaurantID: String,
                 postID: String, rating: Double, timestamp: Double,
                 completion: @escaping (_ error: Error?) -> Void) {
        
        let savoredFoodReference = savoredReference.child(restaurantID).child(foodID)
        savoredFoodReference.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            var savoredFood: [String: AnyObject]
            var posts: Dictionary<String, Double>
            var totalRating: Double
            if let value = currentData.value as? [String: AnyObject] {
                savoredFood = value
                posts = value["posts"] as? [String: Double] ?? [:]
                totalRating = value["total_rating"] as? Double ?? 0
            } else {
                savoredFood = [:]
                posts = [:]
                totalRating = 0
            }
            
            totalRating += rating
            posts[postID] = timestamp
            
            savoredFood["posts"] = posts as AnyObject?
            savoredFood["total_rating"] = totalRating as AnyObject?
            
            currentData.value = savoredFood
            
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            completion(error)
        }
    }
    
    func getPostsSavoredFood(_ foodID: String, in restaurantID: String, completion: @escaping (_ posts: [String], _ totalRating: Double) -> Void) {
        let savoredFoodReference = savoredReference.child(restaurantID).child(foodID)
        savoredFoodReference.observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [String: Any],
                let posts = value["posts"] as? [String: Double],
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
    
    func getSavoredFoods(in restaurantID: String, completion: @escaping (_ foods: [(String/*foodID*/, Double/*total rating*/, [String]/*postIDs*/)]) -> Void) {
        let restaurantReference = savoredReference.child(restaurantID)
        restaurantReference.observeSingleEvent(of: .value) { (snapshot) in
            var response: [(String, Double, [String])] = []
            if let value = snapshot.value as? [String: Any] {
                for savoredFood in value {
                    let foodID = savoredFood.key
                    if let value = savoredFood.value as? [String: Any] {
                        let posts = value["posts"] as? [String: Double] ?? [:]
                        let totalRating = value["total_rating"] as? Double ?? 0
                        var postIDs: [String] = []
                        for post in posts {
                            postIDs.append(post.key)
                        }
                        response.append((foodID, totalRating, postIDs))
                    }
                }
            }
            completion(response)
        }
    }
}

