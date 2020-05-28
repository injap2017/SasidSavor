//
//  FollowCell.swift
//  Savor
//
//  Created by Edgar Sia on 5/26/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class FollowCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    @IBOutlet weak var postCountLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    // MARK: - Properties
    static let identifier = "FollowCell"
    static let nib = UINib.init(nibName: "FollowCell", bundle: nil)
    
    var user: SSUser? {
        didSet {
            userPhotoImageView.image = UIImage.init(named: "account-gray")
            userNameLabel.text = nil
            userFullNameLabel.text = nil
            
            postCount = 0
            
            if let user = self.user {
                
                if let pictureURL = user.profilePictureURL {
                    userPhotoImageView.sd_setImage(with: pictureURL)
                }
                
                userNameLabel.text = user.fullname
                userFullNameLabel.text = user.fullName()
            }
        }
    }
    
    var postCount: Int = 0 {
        didSet {
            let text = "\(postCount) Posts"
            postCountLabel.text = text
        }
    }
    
    var followStatus: FollowStatus = .disabled {
        didSet {
            switch followStatus {
            case .disabled:
                followButton.setTitle(nil, for: .normal)
                followButton.setTitleColor(.systemGray, for: .normal)
                followButton.isEnabled = false
            case .follow:
                followButton.setTitle("Follow", for: .normal)
                followButton.setTitleColor(.systemBlue, for: .normal)
                followButton.isEnabled = true
            case .unfollow:
                followButton.setTitle("Unfollow", for: .normal)
                followButton.setTitleColor(.systemRed, for: .normal)
                followButton.isEnabled = true
            }
        }
    }
}

// MARK: - Actions
extension FollowCell {
    
    @IBAction func follow(_ sender: UIButton) {
        print("follow")
    }
}
