//
//  GeoPostsAPI.swift
//  Savor
//
//  Created by Edgar Sia on 6/26/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase
import GeoFire

class GeoPostsAPI {
    var geoPostsReference = Database.database().reference().child("geo_posts")
    
    var geoFire: GeoFire {
        return GeoFire.init(firebaseRef: geoPostsReference)
    }
    
    
}
