//
//  FeedSquareItem.swift
//  Savor
//
//  Created by Edgar Sia on 4/6/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import MagazineLayout

class FeedSquareItem: MagazineLayoutCollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postPhotoImageView: UIImageView!
    
    // MARK: - Properties
    static let identifier = "FeedSquareItem"
    static let nib = UINib.init(nibName: "FeedSquareItem", bundle: nil)
    
    var feed: Feed? {
        didSet {
            postPhotoImageView.image = UIImage.init(named: "image-off-outline")
            
            if let feed = self.feed {
                postPhotoImageView.image = UIImage.init(named: feed.post_photo)
            }
        }
    }
}

// MARK: - Lifecycle
extension FeedSquareItem {
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // square item has been created in dynamic height rather third fractional width.
        // needs to be square height equal to width
        let layout = super.preferredLayoutAttributesFitting(layoutAttributes)
        layout.size = CGSize.init(width: layout.size.width, height: layout.size.width)
        
        return layout
    }
}
