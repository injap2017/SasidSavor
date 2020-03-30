//
//  YelpX.swift
//  Savor
//
//  Created by Edgar Sia on 3/23/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation
import CDYelpFusionKit

extension CDYelpBusiness {
    
    func detailAddress() -> String {
        var detailAddress = ""
        if let location = self.location {
            if let city = location.city {
                detailAddress += city
            }
            if let addressOne = location.addressOne {
                detailAddress += " " + addressOne
            }
            if let addressTwo = location.addressTwo {
                detailAddress += " " + addressTwo
            }
            if let addressThree = location.addressThree {
                detailAddress += " " + addressThree
            }
        }
        return detailAddress
    }
    
    func firestoreDocument() -> [String: Any] {
        return [
            "name": self.name ?? NSNull(),
            "display_phone": self.displayPhone ?? NSNull(),
            "url": self.url?.absoluteString ?? NSNull(),
            "location": self.location?.firestoreDocument() ?? NSNull(),
            "coordinates": self.coordinates?.firestoreDocument() ?? NSNull()
        ]
    }
    
    func partialDocument() -> [String: Any] {
        return [
            "restaurantID": self.id ?? NSNull(),
            "name": self.name ?? NSNull(),
            "location": self.location?.partialDocument() ?? NSNull()
        ]
    }
}

extension CDYelpLocation {
    
    func firestoreDocument() -> [String: Any] {
        
        return [
            "address_one": self.addressOne ?? NSNull(),
            "address_two": self.addressTwo ?? NSNull(),
            "address_three": self.addressThree ?? NSNull(),
            "city": self.city ?? NSNull(),
            "state": self.state ?? NSNull(),
            "zip_code": self.zipCode ?? NSNull(),
            "country": self.country ?? NSNull(),
            "display_address": self.displayAddress ?? NSNull()
        ]
    }
    
    func partialDocument() -> [String: Any] {
        return [
            "address_one": self.addressOne ?? NSNull(),
            "city": self.city ?? NSNull(),
            "state": self.state ?? NSNull(),
            "country": self.country ?? NSNull()
        ]
    }
}

extension CDYelpCoordinates {
    
    func firestoreDocument() -> [String: Any] {
        return [
            "latitude": self.latitude ?? NSNull(),
            "longitude": self.longitude ?? NSNull()
        ]
    }
}
