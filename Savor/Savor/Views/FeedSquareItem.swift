//
//  FeedSquareItem.swift
//  Savor
//
//  Created by Edgar Sia on 4/6/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import MagazineLayout
import SDWebImage

class FeedSquareItem: MagazineLayoutCollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postPhotoImageView: UIImageView!
    
    // MARK: - Properties
    static let identifier = "FeedSquareItem"
    static let nib = UINib.init(nibName: "FeedSquareItem", bundle: nil)
    
    var feed: SSPost? {
        didSet {
            postPhotoImageView.image = UIImage.init(named: "image-off-outline")
            
            if let feed = self.feed {
                
                if let photos = feed.photos,
                    let first = photos.first,
                    let fullPath = first["full_url"],
                    let fullURL = URL.init(string: fullPath) {
                    postPhotoImageView.sd_setImage(with: fullURL)
                }
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
