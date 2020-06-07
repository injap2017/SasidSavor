//
//  FeedAPI.swift
//  Savor
//
//  Created by Edgar Sia on 6/7/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase

class FeedAPI {
    var feedReference = Database.database().reference().child("feed")
    
    func getRecentPosts(start timestamp: Double? = nil, limit: UInt, completionHandler: @escaping ([SSPost]) -> Void) {
        let userID = SSUser.authCurrentUser.uid
        let query = feedReference.child(userID).queryOrdered(byChild: "timestamp")
        var startingLimitedQuery: DatabaseQuery
        if let latestPostTimestamp = timestamp, latestPostTimestamp > 0 {
            startingLimitedQuery = query.queryStarting(atValue: latestPostTimestamp + 1, childKey: "timestamp").queryLimited(toLast: limit)
        } else {
            startingLimitedQuery = query.queryLimited(toLast: limit)
        }
        
        startingLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let items = snapshot.children.allObjects as! [DataSnapshot]
            
            var results: [SSPost] = []
            
            let dispatchGroup = DispatchGroup()
            for item in items {
                dispatchGroup.enter()
                APIs.Posts.getPost(of: item.key) { (post) in
                    results.append(post)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                results.sort(by: {$0.timestamp > $1.timestamp})
                completionHandler(results)
            }
        })
    }
    
    func getOldPosts(start timestamp: Double, limit: UInt, completionHandler: @escaping ([SSPost]) -> Void) {
        let userID = SSUser.authCurrentUser.uid
        let query = feedReference.child(userID).queryOrdered(byChild: "timestamp")
        let endingLimitedQuery = query.queryEnding(atValue: timestamp - 1, childKey: "timestamp").queryLimited(toLast: limit)
        
        endingLimitedQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            let items = snapshot.children.allObjects as! [DataSnapshot]
         
            var results: [SSPost] = []
            
            let dispatchGroup = DispatchGroup()
            for item in items {
                dispatchGroup.enter()
                APIs.Posts.getPost(of: item.key) { (post) in
                    results.append(post)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                results.sort(by: {$0.timestamp > $1.timestamp })
                completionHandler(results)
            }
        })
    }
}
