//
//  SavorData.swift
//  Savor
//
//  Created by Edgar Sia on 3/2/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Foundation
import FirebaseStorage

class SavorData {
    class func profilePicturesStorageReference(of uid: String) -> StorageReference {
        return Storage.storage().reference().child("profilePictures").child("\(uid).png")
    }
}
