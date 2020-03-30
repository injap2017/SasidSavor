//
//  SavorData.swift
//  Savor
//
//  Created by Edgar Sia on 3/2/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation
import Firebase
import arek

class SavorData {
    
    // MARK: - API Keys
    class APIKey {
        static let googlePlaces = "AIzaSyD0LCguIcWnEQYXrozUHD4mKa3U2CK9DKQ"
        static let yelp = "1mm0msj8c33c_6dMgNjlFX-GocP6_OW6yc-EwYFYEwI46YhCswKvsPHyTnEO6d8NfLYbK4nRW2BRxuk-9YEnoc2AxH6kYDlBuqVR0C6N6SNaD2TtvdxgvA34VYF2XnYx"
    }
    
    // MARK: - FireBase
    class FireBase {
        private static let storage = Storage.storage()
        private static let firestore = Firestore.firestore()
        
        // storage references
        class func profilePictureStorageReference(of uid: String) -> StorageReference {
            return storage.reference(withPath: "\(uid)/profilePicture/png")
        }
        
        class func postPictureFullStorageReference(of uid: String, postID: String, nth: Int) -> StorageReference {
            return storage.reference(withPath: "\(uid)/posts/\(postID)/full/jpg/\(nth)")
        }
        
        // firestore references
        class func postsReference() -> CollectionReference {
            return firestore.collection("posts")
        }
        
        class func restaurantsReference() -> CollectionReference {
            return firestore.collection("restaurants")
        }
        
        class func foodsReference()  -> CollectionReference {
            return firestore.collection("foods")
        }
        
        class func peopleReference() -> CollectionReference {
            return firestore.collection("people")
        }
        
        class func feedReference() -> CollectionReference {
            return firestore.collection("feed")
        }
        
        class func savoredReference() -> CollectionReference {
            return firestore.collection("savored")
        }
        
        // Authentication
        class var isAuthenticated: Bool {
            get {
                return Auth.auth().currentUser != nil
            }
        }
    }

    // MARK: - Permission
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
