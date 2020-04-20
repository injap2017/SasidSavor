//
//  FeedDetailCell.swift
//  Savor
//
//  Created by Edgar Sia on 4/20/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos

class FeedDetailCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postPhotoImageView: UIImageView!
    
    @IBOutlet weak var postDescriptionLabel: UILabel!
    
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
            
            postDescriptionLabel.text = nil
            
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
            
            if let feed = self.feed {
                
                if let photos = feed.photos,
                    let first = photos.first,
                    let fullPath = first["full_url"],
                    let fullURL = URL.init(string: fullPath) {
                    postPhotoImageView.sd_setImage(with: fullURL)
                }
                
                postDescriptionLabel.text = feed.text
                
                postScore.rating = feed.rating // colour by score
                userNameButton.setTitle(feed.author?.fullname, for: .normal)
                
                let timestampDate = Date(timeIntervalSince1970: feed.timestamp/1000)
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
extension FeedDetailCell {
    
    @IBAction func user(_ sender: UIButton) {
        print("user")
    }
    
    @IBAction func commentsLikes(_ sender: UIButton) {
        print("comments and likes")
    }
}
