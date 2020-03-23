//
//  SavorData.swift
//  Savor
//
//  Created by Edgar Sia on 3/2/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

class SavorData {
    class func profilePicturesStorageReference(of uid: String) -> StorageReference {
        return Storage.storage().reference().child("profilePictures").child("\(uid).png")
    }
    
    class var isAuthenticated: Bool {
        get {
            return Auth.auth().currentUser != nil
        }
    }
    
    static let googlePlacesAPIKey = "AIzaSyD0LCguIcWnEQYXrozUHD4mKa3U2CK9DKQ"
    static let yelpAPIKey = "1mm0msj8c33c_6dMgNjlFX-GocP6_OW6yc-EwYFYEwI46YhCswKvsPHyTnEO6d8NfLYbK4nRW2BRxuk-9YEnoc2AxH6kYDlBuqVR0C6N6SNaD2TtvdxgvA34VYF2XnYx"
}
