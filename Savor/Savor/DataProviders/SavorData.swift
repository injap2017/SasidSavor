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
import FirebaseFirestore
import arek

class SavorData {
    
    static let googlePlacesAPIKey = "AIzaSyD0LCguIcWnEQYXrozUHD4mKa3U2CK9DKQ"
    static let yelpAPIKey = "1mm0msj8c33c_6dMgNjlFX-GocP6_OW6yc-EwYFYEwI46YhCswKvsPHyTnEO6d8NfLYbK4nRW2BRxuk-9YEnoc2AxH6kYDlBuqVR0C6N6SNaD2TtvdxgvA34VYF2XnYx"
    
    class func profilePicturesStorageReference(of uid: String) -> StorageReference {
        return Storage.storage().reference().child("profilePictures").child("\(uid).png")
    }
    
    class func foodNamesReference()  -> CollectionReference {
        return Firestore.firestore().collection("foodNames")
    }
    
    class var isAuthenticated: Bool {
        get {
            return Auth.auth().currentUser != nil
        }
    }
    
    class Permission {
        private class func reEnablePopupData(for permission: String) -> ArekPopupData {
            return ArekPopupData.init(title: "\(permission) is currently disabled",
                                                              message: "Please enable access to \(permission) in the Settings app.",
                                                              allowButtonTitle: "Settings", denyButtonTitle: "Cancel",
                                                              type: .native)
        }
        
        private class func configuration() -> ArekConfiguration {
            return ArekConfiguration.init(frequency: .Always, presentInitialPopup: false, presentReEnablePopup: true)
        }
        
        static let photos = ArekPhoto.init(configuration: configuration(), initialPopupData: nil, reEnablePopupData: reEnablePopupData(for: "Photos"))
        static let camera = ArekCamera.init(configuration: configuration(), initialPopupData: nil, reEnablePopupData: reEnablePopupData(for: "Camera"))
        static let locationWhenInUse = ArekLocationWhenInUse.init(configuration: configuration(), initialPopupData: nil, reEnablePopupData: reEnablePopupData(for: "Location"))
    }
}
