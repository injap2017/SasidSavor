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
    
    // upload initial foods
    func initializeDatabase() {
        let foods = [["name":"Alu Mattor Gobi"],
                     ["name":"Tandoori Mixed Grill"],
                     ["name":"Vegetable Samosa"],
                     ["name":"Chana Saag"],
                     ["name":"Butter Chicken"],
                     ["name":"Saag Paneer"],
                     ["name":"Basmati Rice"],
                     ["name":"Gulab Jaman"],
                     ["name":"Chicken Curry"],
                     ["name":"Chana Masala"],
                     ["name":"Chicken Tikka Masala"]]
        
        for food in foods {
            let foodReference = foodsReference.childByAutoId()
            foodReference.setValue(food)
        }
    }
}
