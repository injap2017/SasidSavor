//
//  SSRestaurant.swift
//  Savor
//
//  Created by Edgar Sia on 4/1/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation

class SSRestaurant {
    var restaurantID: String
    var name: String
    var displayPhone: String
    var url: String
    var location: SSLocation?
    var coordinates: SSCoordinates?
    
    init(id: String, value: [String: Any]) {
        self.restaurantID = id
        self.name = value["name"] as? String ?? ""
        self.displayPhone = value["display_phone"] as? String ?? ""
        self.url = value["url"] as? String ?? ""
        if let locationDictionary = value["location"] as? [String: Any] {
            self.location = SSLocation.init(dictionary: locationDictionary)
        }
        if let coordinatesDictionary = value["coordinates"] as? [String: Any] {
            self.coordinates = SSCoordinates.init(dictionary: coordinatesDictionary)
        }
    }
    
    convenience init(dictionary: [String: Any]) {
        let restaurantID = dictionary["restaurantID"] as? String ?? ""
        self.init(id: restaurantID, value: dictionary)
    }
}

extension SSRestaurant {
    
    func address() -> String {
        var address = name + "\n"
        if let location = self.location {
            address += location.city + ", " + location.state
        }
        return address
    }
}
