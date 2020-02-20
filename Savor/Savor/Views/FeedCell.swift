//
//  FeedCell.swift
//  Savor
//
//  Created by Edgar Sia on 12/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos

class FeedCell: UITableViewCell {
    
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
    static let identifier = "feedCell"
    
    var feed: Feed? {
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
                postPhotoImageView.image = UIImage.init(named: feed.post_photo)
                
                postTitleLabel.text = feed.post_title
                postDescriptionLabel.text = feed.post_description
                restaurantNameAddressLabel.text = feed.restaurant_name + "\n" + feed.restaurant_address
                
                postScore.rating = feed.post_score // colour by score
                userNameButton.setTitle(feed.user_name, for: .normal)
                
                postDateLabel.text = "Mon" // date format
                
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
            }
        }
    }
}

// MARK: - Actions
extension FeedCell {
    
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
