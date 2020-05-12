//
//  API.swift
//  Savor
//
//  Created by Edgar Sia on 4/2/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation

struct APIs {
    static var Posts = PostsAPI()
    static var Restaurants = RestaurantsAPI()
    static var Savored = SavoredAPI()
    static var Foods = FoodsAPI()
    static var Likes = LikesAPI()
    static var Comments = CommentsAPI()
    static var CommentCollection = CommentCollectionAPI()
    static var People = PeopleAPI()
}
