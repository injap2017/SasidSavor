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
    
    convenience init(dictionary: [String: Any]) {
        let foodID = dictionary["foodID"] as? String ?? ""
        self.init(id: foodID, value: dictionary)
    }
    
    convenience init(snapshot: DataSnapshot) {
        let foodID = snapshot.key
        let value = snapshot.value as! [String: Any]
        self.init(id: foodID, value: value)
    }
    
    func partialDocument() -> [String: Any] {
        return [
            "foodID": self.foodID,
            "name": self.name
        ]
    }
}
