//
//  RestaurantAPI.swift
//  Savor
//
//  Created by Edgar Sia on 4/1/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class RestaurantsAPI {
    var restaurantsReference = Database.database().reference().child("restaurants")
    
    func getRestaurant(of id: String, completion: @escaping (SSRestaurant) -> Void) {
        restaurantsReference.child(id).observeSingleEvent(of: .value) { (snapshot) in
            let restaurant = SSRestaurant.init(snapshot: snapshot)
            completion(restaurant)
        }
    }
}
