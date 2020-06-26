//
//  GeoFeedAPI.swift
//  Savor
//
//  Created by Edgar Sia on 6/26/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation
import GeoFire

class GeoFeedAPI {
    var geoFeedReference = Database.database().reference().child("geo_feed")
    
    func geoFeedReference(ofUser userID: String) -> DatabaseReference {
        return geoFeedReference.child(userID)
    }
    
    func geoFire(ofUser userID: String) -> GeoFire {
        return GeoFire.init(firebaseRef: geoFeedReference(ofUser: userID))
    }
    
    
}
