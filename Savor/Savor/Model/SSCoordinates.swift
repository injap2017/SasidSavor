//
//  SSCoordinates.swift
//  Savor
//
//  Created by Edgar Sia on 4/1/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation

class SSCoordinates {
    var latitude: Double
    var longitude: Double
    
    init(dictionary: [String: Any]) {
        self.latitude = dictionary["latitude"] as? Double ?? 0.0
        self.longitude = dictionary["longitude"] as? Double ?? 0.0
    }
}
