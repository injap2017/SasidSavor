//
//  FollowCell.swift
//  Savor
//
//  Created by Edgar Sia on 5/26/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Firebase

protocol FollowCellDelegate {
    func followed(_ data: (SSUser, Int))
    func unfollowed(_ data: (SSUser, Int))
}

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
    
    var delegate: FollowCellDelegate?
    
    private var postCountHandle: UInt?
    var postCount: Int = 0 {
        didSet {
            let text = "\(postCount) Posts"
            postCountLabel.text = text
        }
    }
    
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
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var userID: String?
    
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
                
                // below install all observers
                postCountHandle = APIs.People.observePostCount(ofUser: user.uid) { (count) in
                    self.postCount = count
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
    
    deinit {
        self.removeAllObservers()
    }
}

// MARK: - Lifecycle
extension FollowCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        /* iOS dequeueReusableCell returns previus created and used cell which still has lived handles, hence we have to release the handles before using it so that prevent listen handle duplicated into the ui elements */
        self.removeAllObservers()
    }
}

// MARK: - Functions
extension FollowCell {
    
    func removeAllObservers() {
        
        if let user = self.user {
            if let postCountHandle = self.postCountHandle {
                APIs.People.removePostCountObserver(ofUser: user.uid, withHandle: postCountHandle)
                self.postCountHandle = nil
                
                self.postCount = 0
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
extension FollowCell {
    
    @IBAction func follow(_ sender: UIButton) {
        if let user = self.user {
            sender.isEnabled = false
            switch self.followStatus {
            case .follow:
                APIs.People.followed(userID: user.uid)
                self.delegate?.followed((user, postCount))
            case .unfollow:
                APIs.People.unfollowed(userID: user.uid)
                self.delegate?.unfollowed((user, postCount))
            default:
                break
            }
            sender.isEnabled = true
        }
    }
}
