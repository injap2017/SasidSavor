//
//  SSPost.swift
//  Savor
//
//  Created by Edgar Sia on 4/1/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class SSPost {
    var postID: String
    var text: String
    var rating: Double
    var author: SSUser?
    var restaurant: SSRestaurant?
    var food: SSFood?
    var photos: [[String: String]]?
    var timestamp: Double
    
    convenience init?(snapshot: DataSnapshot) {
        guard snapshot.exists() else {
            return nil
        }
        
        let postID = snapshot.key
        let value = snapshot.value as! [String: Any]
        self.init(id: postID, value: value)
    }
    
    init(id: String, value: [String: Any]) {
        self.postID = id
        self.text = value["text"] as? String ?? ""
        self.rating = value["rating"] as? Double ?? 0.0
        if let author = value["author"] as? [String: Any] {
            self.author = SSUser.init(dictionary: author)
        }
        if let restaurant = value["restaurant"] as? [String: Any] {
            self.restaurant = SSRestaurant.init(dictionary: restaurant)
        }
        if let food = value["food"] as? [String: Any] {
            self.food = SSFood.init(dictionary: food)
        }
        if let photos = value["photos"] as? [[String: String]] {
            self.photos = photos
        }
        self.timestamp = value["timestamp"] as? Double ?? 0.0
    }
}
