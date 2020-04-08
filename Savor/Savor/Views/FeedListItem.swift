//
//  FeedListItem.swift
//  Savor
//
//  Created by Edgar Sia on 4/6/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import MagazineLayout
import Cosmos
import SDWebImage

class FeedListItem: MagazineLayoutCollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var restaurantNameAddressLabel: UILabel!
    
    @IBOutlet weak var postScore: CosmosView!
    @IBOutlet weak var userNameButton: UIButton!
    
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var commentsImageView: UIImageView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "FeedListItem"
    static let nib = UINib.init(nibName: "FeedListItem", bundle: nil)
    
    var feed: SSPost? {
        didSet {
            postPhotoImageView.image = UIImage.init(named: "image-off-outline")
            
            postTitleLabel.text = nil
            postDescriptionLabel.text = nil
            restaurantNameAddressLabel.text = nil
            
            postScore.rating = 0.0
            userNameButton.setTitle(nil, for: .normal)
            
            postDateLabel.text = nil
            
            commentsImageView.isHidden = true
            commentsImageView.image = UIImage.init(named: "chat-gray")
            commentsCountLabel.isHidden = true
            commentsCountLabel.text = nil
            
            likesImageView.isHidden = true
            likesImageView.image = UIImage.init(named: "heart-gray")
            likesCountLabel.isHidden = true
            likesCountLabel.text = nil
            
            commentButton.setImage(UIImage.init(named: "chat-outline-gray"), for: .normal)
            likeButton.setImage(UIImage.init(named: "heart-outline-gray"), for: .normal)
            
            if let feed = self.feed {
                
                if let photos = feed.photos,
                    let first = photos.first,
                    let fullPath = first["full_url"],
                    let fullURL = URL.init(string: fullPath) {
                    postPhotoImageView.sd_setImage(with: fullURL)
                }
                
                postTitleLabel.text = feed.food?.name
                postDescriptionLabel.text = feed.text
                restaurantNameAddressLabel.text = feed.restaurant?.address()
                
                postScore.rating = feed.rating // colour by score
                userNameButton.setTitle(feed.author?.fullname, for: .normal)
                
                let timestampDate = Date(timeIntervalSince1970: feed.timestamp)
                postDateLabel.text = SavorData.Accessories.timestampText(timestampDate)
/*
                if feed.comments_count > 0 {
                    commentsImageView.isHidden = false
                    
                    commentsCountLabel.isHidden = false
                    commentsCountLabel.text = "\(feed.comments_count)"
                }
                
                if feed.likes_count > 0 {
                    likesImageView.isHidden = false
                    likesCountLabel.isHidden = false
                    likesCountLabel.text = "\(feed.likes_count)"
                }
                
                if feed.commented_by_u {
                    commentButton.setImage(UIImage.init(named: "chat-green"), for: .normal)
                    commentsImageView.image = UIImage.init(named: "chat-green")
                }
                
                if feed.liked_by_u {
                    likeButton.setImage(UIImage.init(named: "heart-red"), for: .normal)
                    likesImageView.image = UIImage.init(named: "heart-red")
                }
 */
            }
        }
    }
}

// MARK: - Actions
extension FeedListItem {
    
    @IBAction func user(_ sender: UIButton) {
        print("user")
    }
    
    @IBAction func commentsLikes(_ sender: UIButton) {
        print("comments and likes")
    }
    
    @IBAction func like(_ sender: UIButton) {
        print("like")
    }
    
    @IBAction func comment(_ sender: UIButton) {
        print("comment")
    }
}
