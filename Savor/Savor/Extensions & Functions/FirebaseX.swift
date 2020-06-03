//
//  FirebaseX.swift
//  Savor
//
//  Created by Edgar Sia on 6/3/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

extension User {
    
    func requestProfileChange(displayName: String? = nil, photoURL: URL? = nil,
                              completion: @escaping (_ error: Error?) -> Void) {
        let request = self.createProfileChangeRequest()
        if let displayName = displayName { request.displayName = displayName }
        if let photoURL = photoURL { request.photoURL = photoURL }
        request.commitChanges { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
}
