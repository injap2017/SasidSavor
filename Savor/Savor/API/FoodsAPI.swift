//
//  FoodsAPI.swift
//  Savor
//
//  Created by Edgar Sia on 4/23/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class FoodsAPI {
    var foodsReference = Database.database().reference().child("foods")
    
    func getFood(of id: String, completion: @escaping (SSFood) -> Void) {
        foodsReference.child(id).observeSingleEvent(of: .value) { (snapshot) in
            let food = SSFood.init(snapshot: snapshot)
            completion(food)
        }
    }
}
