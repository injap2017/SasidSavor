//
//  SSLocation.swift
//  Savor
//
//  Created by Edgar Sia on 4/1/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation

class SSLocation {
    var addressOne: String
    var addressTwo: String
    var addressThree: String
    var city: String
    var state: String
    var zipCode: String
    var country: String
    var displayAddress: [String]?
    
    init(dictionary: [String: Any]) {
        self.addressOne = dictionary["address_one"] as? String ?? ""
        self.addressTwo = dictionary["address_two"] as? String ?? ""
        self.addressThree = dictionary["address_three"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.state = dictionary["state"] as? String ?? ""
        self.zipCode = dictionary["zip_code"] as? String ?? ""
        self.country = dictionary["country"] as? String ?? ""
        if let displayAddress = dictionary["display_address"] as? [String] {
            self.displayAddress = displayAddress
        }
    }
}
