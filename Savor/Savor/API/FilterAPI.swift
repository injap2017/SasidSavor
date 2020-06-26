//
//  FilterAPI.swift
//  Savor
//
//  Created by Edgar Sia on 6/25/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase
import GeoFire

class CompoundKey {
    var timestamp: Double
    var rating: Double
    var postID: String
    
    init(post: SSPost) {
        self.timestamp = post.timestamp
        self.rating = post.rating
        self.postID = post.postID
    }
    
    init(timestamp: Double, rating: Double, postID: String) {
        self.timestamp = timestamp
        self.rating = rating
        self.postID = postID
    }
    
    init?(key: String) {
        let subKeys = key.split(separator: ";")
        guard subKeys.count == 3 else {
            return nil
        }
        
        let timestampText = String(subKeys[0])
        let ratingText = String(subKeys[1])
        let postID = String(subKeys[2])
        
        guard let timestamp = Double(timestampText),
            let rating = Double(ratingText) else {
            return nil
        }
        
        self.timestamp = timestamp
        self.rating = rating
        self.postID = postID
    }
    
    var key: String {
        get {
            return "\(timestamp)" + ";" + "\(rating)" + ";" + postID
        }
    }
}

class FilterAPI {
    
    func getPosts(source: FeedSource, minimumRating: Float, areaOfInterest: Double, at center: CLLocation?, completion: @escaping (_ posts: [String]) -> Void) {
        
        // select georef
        // if areaofinterest
        //      create geoquery
        //      observe all keys
        //      remove observers
        //      return with all keys
        // else
        //      get all keys
        //      return with all keys
        // break keys into Timestamp + Rating + ID
        // get keys whose Rating is higher than minimumRating
        // sort keys by Timestamp
        // return with all IDs
        
        let geoPostsReference = APIs.GeoPosts.geoPostsReference
        
        let userID = SSUser.authCurrentUser.uid
        let geoFeedReference = APIs.GeoFeed.geoFeedReference(ofUser: userID)
        
        var geoFireReference: DatabaseReference
        switch source {
        case .allPosts:
            geoFireReference = geoPostsReference
        default:
            geoFireReference = geoFeedReference
        }
        
        let dispatchGroup = DispatchGroup()
        
        var keys: [String] = []
        if areaOfInterest == -1 {
            dispatchGroup.enter()
            let query = geoFireReference.queryOrderedByKey().queryLimited(toLast: 1000)
            query.observeSingleEvent(of: .value) { (snapshot) in
                let items = snapshot.children.allObjects as! [DataSnapshot]
                for item in items {
                    keys.append(item.key)
                }
                
                dispatchGroup.leave()
            }
        } else if let center = center {
            dispatchGroup.enter()
            let geoFire = GeoFire.init(firebaseRef: geoFireReference)
            let geoQuery = geoFire.query(at: center, withRadius: areaOfInterest)
            let queryHandle = geoQuery.observe(.keyEntered, with: { (key, location) in
                keys.append(key)
            })
            geoQuery.observeReady {
                geoQuery.removeObserver(withFirebaseHandle: queryHandle)
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            var keysRating: [CompoundKey] = []
            for key in keys {
                if let compoundKey = CompoundKey.init(key: key),
                    compoundKey.rating >= Double(minimumRating) {
                    keysRating.append(compoundKey)
                }
            }
            
            let keysSorted = keysRating.sorted { (first, second) -> Bool in
                return first.timestamp > second.timestamp
            }
            
            let postIDs = keysSorted.map { (key) -> String in
                key.postID
            }
            
            completion(postIDs)
        }
    }
}
