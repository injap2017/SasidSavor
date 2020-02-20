//
//  FeedItem.swift
//  Savor
//
//  Created by Edgar Sia on 13/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit

class FeedItem: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postPhotoImageView: UIImageView!
    
    // MARK: - Properties
    static let identifier = "feedItem"
    
    var feed: Feed? {
        didSet {
            postPhotoImageView.image = UIImage.init(named: "image-off-outline")
            
            if let feed = self.feed {
                postPhotoImageView.image = UIImage.init(named: feed.post_photo)
            }
        }
    }
}
