//
//  ProfilePicturesAPI.swift
//  Savor
//
//  Created by Edgar Sia on 6/3/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class ProfilePicturesAPI {
    var profilePicturesReference = Storage.storage().reference().child("profilePictures")
    
    func uploadPhoto(_ photo: UIImage, ofUser userID: String, completion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        guard let data = photo.jpegData(compressionQuality: 0.5) else {
            print("jpeg data error")
            completion(nil, nil)
            return
        }
        
        let userPhotoReference = profilePicturesReference.child("\(userID).png")
        userPhotoReference.putData(data, metadata: nil) { (metaData, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            userPhotoReference.downloadURL { (url, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                completion(url, nil)
            }
        }
    }
}
