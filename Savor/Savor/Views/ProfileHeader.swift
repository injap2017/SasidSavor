//
//  ProfileHeader.swift
//  Savor
//
//  Created by Edgar Sia on 5/26/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class ProfileHeader: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    var user: SSUser? {
        didSet {
            userPhotoImageView.image = UIImage.init(named: "account-gray")
            userNameLabel.text = nil
            userFullNameLabel.text = nil
            
            followStatus = .disabled
            
            postCount = 0
            followingCount = 0
            followerCount = 0
            
            if let user = self.user {
                
                if let pictureURL = user.profilePictureURL {
                    userPhotoImageView.sd_setImage(with: pictureURL)
                }
                
                userNameLabel.text = user.fullname
                userFullNameLabel.text = user.fullName()
            }
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
    
    var postCount: Int = 0 {
        didSet {
            let title = "\(postCount)\nPosts"
            segmentedControl.setTitle(title, forSegmentAt: 0)
        }
    }
    
    var followingCount: Int = 0 {
        didSet {
            let title = "\(followingCount)\nFollowing"
            segmentedControl.setTitle(title, forSegmentAt: 1)
        }
    }
    
    var followerCount: Int = 0 {
        didSet {
            let title = "\(followingCount)\nFollower"
            segmentedControl.setTitle(title, forSegmentAt: 2)
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
extension ProfileHeader {
    
    private func initialize() {
        // load nib
        Bundle.main.loadNibNamed("ProfileHeader", owner: self, options: nil)
        // add contentview loaded from nib
        addSubview(contentView)
        // bounding
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // multilines in segmented control
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
    }
}

// MARK: - Actions
extension ProfileHeader {
    
    @IBAction func follow(_ sender: UIButton) {
        print("follow")
    }
}
