//
//  RestaurantItemCell.swift
//  Savor
//
//  Created by Edgar Sia on 4/22/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos


class RestaurantItemCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var itemPhotoImageView: UIImageView!
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    @IBOutlet weak var averageScore: CosmosView!
    @IBOutlet weak var postCountLabel: UILabel!
    
    @IBOutlet weak var lastPostDateLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "RestaurantItemCell"
    static let nib = UINib.init(nibName: "RestaurantItemCell", bundle: nil)
    
    var item: (SSFood, Double, Int, SSPost)? {
        didSet {
            itemPhotoImageView.image = UIImage.init(named: "image-off-outline")
            
            itemTitleLabel.text = nil
            
            postCountLabel.text = nil
            averageScore.rating = 0
            
            lastPostDateLabel.text = nil
            
            if let item = item {
                
                if let photos = item.3.photos,
                    let first = photos.first,
                    let fullPath = first["full_url"],
                    let fullURL = URL.init(string: fullPath) {
                    itemPhotoImageView.sd_setImage(with: fullURL)
                }
                
                itemTitleLabel.text = item.0.name
                
                let postCount = item.2
                let averageRating = postCount == 0 ? 0.0 : item.1 / Double(postCount)
                averageScore.rating = averageRating // colour by score
                
                postCountLabel.text = "\(item.2) posts"
                
                let timestampDate = Date(timeIntervalSince1970: item.3.timestamp)
                lastPostDateLabel.text = SavorData.Accessories.timestampText(timestampDate)
            }
        }
    }
}
