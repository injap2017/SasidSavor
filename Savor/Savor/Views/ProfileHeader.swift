//
//  ProfileHeader.swift
//  Savor
//
//  Created by Edgar Sia on 5/26/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Firebase

protocol ProfileHeaderDelegate {
    func followed()
    func unfollowed()
}

class ProfileHeader: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    var delegate: ProfileHeaderDelegate?
    
    private var followedHandle: UInt?
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
    
    private var postCountHandle: UInt?
    var postCount: Int = 0 {
        didSet {
            let title = "\(postCount)\nPosts"
            segmentedControl.setTitle(title, forSegmentAt: 0)
        }
    }
    
    private var followingCountHandle: UInt?
    var followingCount: Int = 0 {
        didSet {
            let title = "\(followingCount)\nFollowing"
            segmentedControl.setTitle(title, forSegmentAt: 1)
        }
    }
    
    private var followerCountHandle: UInt?
    var followerCount: Int = 0 {
        didSet {
            let title = "\(followerCount)\nFollowers"
            segmentedControl.setTitle(title, forSegmentAt: 2)
        }
    }
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var userID: String?
    
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
                
                // below install all observers
                postCountHandle = APIs.People.observePostCount(ofUser: user.uid) { (count) in
                    self.postCount = count
                }
                
                followingCountHandle = APIs.People.observeFollowingCount(ofUser: user.uid) { (count) in
                    self.followingCount = count
                }
                
                followerCountHandle = APIs.People.observeFollowerCount(ofUser: user.uid) { (count) in
                    self.followerCount = count
                }
                
                handle = Auth.auth().addStateDidChangeListener { (auth, _user) in
                    if SSUser.isAuthenticated {
                        if SSUser.authCurrentUser.uid == user.uid {
                            self.followStatus = .disabled
                            return
                        }
                        self.userID = SSUser.authCurrentUser.uid
                        self.followedHandle = APIs.People.observeFollowed(user: user.uid, fromUser: self.userID!) { (followed) in
                            self.followStatus = followed ? .unfollow : .follow
                        }
                    } else {
                        if let followedHandle = self.followedHandle, let userID = self.userID {
                            APIs.People.removeFollowedObserver(ofUser: user.uid, fromUser: userID, withHandle: followedHandle)
                            self.followedHandle = nil
                            
                            self.followStatus = .disabled
                        }
                        self.userID = nil
                    }
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
    
    deinit {
        self.removeAllObservers()
    }
}

// MARK: - Lifecycle
extension ProfileHeader {
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        self.removeAllObservers()
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
    
    func removeAllObservers() {
        
        if let user = self.user {
            if let postCountHandle = self.postCountHandle {
                APIs.People.removePostCountObserver(ofUser: user.uid, withHandle: postCountHandle)
                self.postCountHandle = nil
                
                self.postCount = 0
            }
            if let followingCountHandle = self.followingCountHandle {
                APIs.People.removeFollowingCountObserver(ofUser: user.uid, withHandle: followingCountHandle)
                self.followingCountHandle = nil
                
                self.followingCount = 0
            }
            if let followerCountHandle = self.followerCountHandle {
                APIs.People.removeFollowerCountObserver(ofUser: user.uid, withHandle: followerCountHandle)
                self.followerCountHandle = nil
                
                self.followerCount = 0
            }
            if let followedHandle = self.followedHandle, let userID = self.userID {
                APIs.People.removeFollowedObserver(ofUser: user.uid, fromUser: userID, withHandle: followedHandle)
                self.followedHandle = nil
                
                self.followStatus = .disabled
            }
            self.userID = nil
        }
        
        if let handle = self.handle {
            Auth.auth().removeStateDidChangeListener(handle)
            
            self.handle = nil
        }
    }
}

// MARK: - Actions
extension ProfileHeader {
    
    @IBAction func follow(_ sender: UIButton) {
        if let user = self.user {
            sender.isEnabled = false
            switch self.followStatus {
            case .follow:
                APIs.People.followed(userID: user.uid)
                self.delegate?.followed()
            case .unfollow:
                APIs.People.unfollowed(userID: user.uid)
                self.delegate?.unfollowed()
            default:
                break
            }
            sender.isEnabled = true
        }
    }
}
