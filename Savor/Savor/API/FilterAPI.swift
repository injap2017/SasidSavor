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
        
        let timestampText = subKeys[0].replacingOccurrences(of: "*", with: ".")
        let ratingText = String(subKeys[1]).replacingOccurrences(of: "*", with: ".")
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
            let timestampText = "\(timestamp)".replacingOccurrences(of: ".", with: "*")
            let ratingText = "\(rating)".replacingOccurrences(of: ".", with: "*")
            return timestampText + ";" + ratingText + ";" + postID
        }
    }
}

class FilterAPI {
    
    func getPosts(source: FeedSource, minimumRating: Float, areaOfInterest: Double, at center: CLLocation?, completion: @escaping (_ posts: [String]) -> Void) {
        
        // 5 score rating means higher than 4.5
        let adjustedMinimumRating = minimumRating >= 4.5 ? 4.5 : minimumRating
        
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
        // get keys whose Rating is higher than adjustedMinimumRating
        // sort keys by Timestamp
        // return with all IDs
        
        var geoFireReference: DatabaseReference
        switch source {
        case .allPosts:
            geoFireReference = APIs.GeoPosts.geoPostsReference
        default:
            let userID = SSUser.authCurrentUser.uid
            geoFireReference = APIs.GeoFeed.geoFeedReference(ofUser: userID)
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
            let miles = Measurement.init(value: areaOfInterest, unit: UnitLength.miles)
            let kilometers = miles.converted(to: UnitLength.kilometers)
            let geoQuery = geoFire.query(at: center, withRadius: kilometers.value)
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
                    compoundKey.rating >= Double(adjustedMinimumRating) {
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
