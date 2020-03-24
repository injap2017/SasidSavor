//
//  FoodName.swift
//  Savor
//
//  Created by Edgar Sia on 3/24/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation

struct FoodName {
    var id: Int
    var name: String
    
    init(from dictionary: [String: Any]) {
        self.id = dictionary["id"] as? Int ?? 0
        self.name = dictionary["name"] as? String ?? ""
    }
}
