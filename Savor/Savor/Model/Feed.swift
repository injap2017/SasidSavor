//
//  Feed.swift
//  Savor
//
//  Created by Edgar Sia on 12/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import Foundation

class Feed {
    var post_title: String // post_id
    var post_description: String
    var post_photo: String
    var post_date: String
    var post_score: Double
    var user_name: String // user_id
    var restaurant_name: String // place_id
    var restaurant_address: String
    var comments_count: Int
    var likes_count: Int
    var commented_by_u: Bool
    var liked_by_u: Bool
    
    init(post_title: String,
         post_description: String,
         post_photo: String,
         post_date: String,
         post_score: Double,
         user_name: String,
         restaurant_name: String,
         restaurant_address: String,
         comments_count: Int,
         likes_count: Int,
         commented_by_u: Bool,
         liked_by_u: Bool) {
        
        self.post_title = post_title
        self.post_description = post_description
        self.post_photo = post_photo
        self.post_date = post_date
        self.post_score = post_score
        self.user_name = user_name
        self.restaurant_name = restaurant_name
        self.restaurant_address = restaurant_address
        self.comments_count = comments_count
        self.likes_count = likes_count
        self.commented_by_u = commented_by_u
        self.liked_by_u = liked_by_u
    }
}
