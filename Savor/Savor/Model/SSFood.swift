//
//  SSFood.swift
//  Savor
//
//  Created by Edgar Sia on 3/30/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class SSFood {
    var foodID: String
    var name: String
    
    init(id: String, value: [String: Any]) {
        self.foodID = id
        self.name = value["name"] as? String ?? ""
    }
    
    func partialDocument() -> [String: Any] {
        return [
            "foodID": self.foodID,
            "name": self.name
        ]
    }
}
