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
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var restaurantNameAddressLabel: UILabel!
    @IBOutlet weak var postScore: CosmosView!
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    var feed: SSPost? {
        didSet {
            postTitleLabel.text = nil
            restaurantNameAddressLabel.text = nil
            
            postScore.rating = 0.0
            
            if let feed = self.feed {
                postTitleLabel.text = feed.food?.name
                restaurantNameAddressLabel.text = feed.restaurant?.address()
                
                postScore.rating = feed.rating // colour by score
                
                if let photos = feed.photos {
                    var imageInputs: [SDWebImageSource] = []
                    for photo in photos {
                        if let fullPath = photo["full_url"],
                            let fullURL = URL.init(string: fullPath) {
                            imageInputs.append(SDWebImageSource.init(url: fullURL))
                        }
                    }
                    
                    imageSlideShow.setImageInputs(imageInputs)
                }
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
