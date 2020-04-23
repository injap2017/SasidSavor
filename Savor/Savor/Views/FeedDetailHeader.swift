//
//  FeedDetailHeader.swift
//  Savor
//
//  Created by Edgar Sia on 4/17/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos
import ImageSlideshow

class FeedDetailHeader: UIView {

    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var restaurantNameAddressLabel: UILabel!
    @IBOutlet weak var averageScore: CosmosView!
    @IBOutlet weak var postCountLabel: UILabel!
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    var data: (SSFood, Double, [SSPost], SSRestaurant)? {
        didSet {
            itemTitleLabel.text = nil
            restaurantNameAddressLabel.text = nil
            
            averageScore.rating = 0.0
            postCountLabel.text = nil
            
            if let data = self.data {
                itemTitleLabel.text = data.0.name
                restaurantNameAddressLabel.text = data.3.address()
                
                let postCount = data.2.count
                let averageRating = postCount == 0 ? 0.0 : data.1 / Double(postCount)
                averageScore.rating = averageRating // colour by score
                
                var imageInputs: [SDWebImageSource] = []
                for post in data.2 {
                    if let photos = post.photos {
                        for photo in photos {
                            if let fullPath = photo["full_url"],
                                let fullURL = URL.init(string: fullPath) {
                                imageInputs.append(SDWebImageSource.init(url: fullURL))
                            }
                        }
                    }
                }
                imageSlideShow.setImageInputs(imageInputs)
                
                let photoCount = imageInputs.count
                postCountLabel.text = "\(postCount) posts, \(photoCount) photos"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
}

// MARK: - Functions
extension FeedDetailHeader {
    
    private func initialize() {
        // load nib
        Bundle.main.loadNibNamed("FeedDetailHeader", owner: self, options: nil)
        // add contentview loaded from nib
        addSubview(contentView)
        // bounding
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
