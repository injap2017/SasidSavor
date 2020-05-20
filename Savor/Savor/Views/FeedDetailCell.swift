//
//  FeedDetailCell.swift
//  Savor
//
//  Created by Edgar Sia on 4/20/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos
import Firebase

protocol FeedDetailCellDelegate {
    func viewProfile(_ author: SSUser)
    func viewComments(_ post: SSPost)
    func viewLikes(_ post: SSPost)
}

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
    static let identifier = "FeedDetailCell"
    static let nib = UINib.init(nibName: "FeedDetailCell", bundle: nil)
    
    var delegate: FeedDetailCellDelegate?
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var userID: String?
    
    private var likeCountHandle: UInt?
    private var likedHandle: UInt?
    
    var likeCount: Int = 0 {
        didSet {
            if likeCount > 0 {
                self.likesImageView.isHidden = false
                self.likesCountLabel.isHidden = false
                self.likesCountLabel.text = "\(likeCount)"
            } else {
                likesImageView.isHidden = true
                likesCountLabel.isHidden = true
                likesCountLabel.text = nil
            }
        }
    }
    
    var liked: Bool = false {
        didSet {
            likesImageView.image = liked ? UIImage.init(named: "heart-red") : UIImage.init(named: "heart-gray")
        }
    }
    
    private var commentCountHandle: UInt?
    private var commentedHandle: UInt?
    
    var commentCount: Int = 0 {
        didSet {
            if commentCount > 0 {
                commentsImageView.isHidden = false
                commentsCountLabel.isHidden = false
                commentsCountLabel.text = "\(commentCount)"
            } else {
                commentsImageView.isHidden = true
                commentsCountLabel.isHidden = true
                commentsCountLabel.text = nil
            }
        }
    }
    
    var commented: Bool = false {
        didSet {
            commentsImageView.image = commented ? UIImage.init(named: "chat-green") : UIImage.init(named: "chat-gray")
        }
    }
    
    var feed: SSPost? {
        didSet {
            postPhotoImageView.image = UIImage.init(named: "image-off-outline")
            
            postDescriptionLabel.text = nil
            
            postScore.rating = 0.0
            userNameButton.setTitle(nil, for: .normal)
            
            postDateLabel.text = nil
            
            likeCount = 0
            liked = false
            
            commentCount = 0
            commented = false
            
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
                
                let timestampDate = Date(timeIntervalSince1970: feed.timestamp)
                postDateLabel.text = SavorData.Accessories.timestampText(timestampDate)
                
                // below install all observers
                likeCountHandle = APIs.Likes.observeLikeCount(of: feed.postID) { (count) in
                    self.likeCount = count
                }
                
                commentCountHandle = APIs.Comments.observeCommentCount(of: feed.postID) { (count) in
                    self.commentCount = count
                }
                
                handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if SSUser.isAuthenticated {
                        self.userID = SSUser.authCurrentUser.uid
                        self.likedHandle = APIs.People.observeLiked(ofPost: feed.postID, fromUser: self.userID!) { (liked) in
                            self.liked = liked
                        }
                        self.commentedHandle = APIs.People.observeCommented(ofPost: feed.postID, fromUser: self.userID!) { (commented) in
                            self.commented = commented
                        }
                    } else {
                        if let likedHandle = self.likedHandle, let userID = self.userID {
                            APIs.People.removeLikedObserver(ofPost: feed.postID, fromUser: userID, withHandle: likedHandle)
                            self.likedHandle = nil
                            
                            self.liked = false
                        }
                        if let commentedHandle = self.commentedHandle, let userID = self.userID {
                            APIs.People.removeCommentedObserver(ofPost: feed.postID, fromUser: userID, withHandle: commentedHandle)
                            self.commentedHandle = nil
                            
                            self.commented = false
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
extension FeedDetailCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        /* iOS dequeueReusableCell returns previus created and used cell which still has lived handles, hence we have to release the handles before using it so that prevent listen handle duplicated into the ui elements */
        self.removeAllObservers()
    }
}

// MARK: - Functions
extension FeedDetailCell {
    
    func removeAllObservers() {
        
        if let feed = self.feed {
            if let likeCountHandle = self.likeCountHandle {
                APIs.Likes.removeLikeCountObserver(of: feed.postID, withHandle: likeCountHandle)
                self.likeCountHandle = nil
                
                self.likeCount = 0
            }
            if let commentCountHandle = self.commentCountHandle {
                APIs.Comments.removeCommentCountObserver(of: feed.postID, withHandle: commentCountHandle)
                self.commentCountHandle = nil
                
                self.commentCount = 0
            }
            if let likedHandle = self.likedHandle, let userID = self.userID {
                APIs.People.removeLikedObserver(ofPost: feed.postID, fromUser: userID, withHandle: likedHandle)
                self.likedHandle = nil
                
                self.liked = false
            }
            if let commentedHandle = self.commentedHandle, let userID = self.userID {
                APIs.People.removeCommentedObserver(ofPost: feed.postID, fromUser: userID, withHandle: commentedHandle)
                self.commentedHandle = nil
                
                self.commented = false
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
extension FeedDetailCell {
    
    @IBAction func user(_ sender: UIButton) {
        if let feed = self.feed,
            let delegate = self.delegate,
            let user = feed.author {
            delegate.viewProfile(user)
        }
    }
    
    @IBAction func commentsLikes(_ sender: UIButton) {
        if let feed = self.feed,
            let delegate = self.delegate {
            if self.commentCount > 0 {
                delegate.viewComments(feed)
                return
            }
            if self.likeCount > 0 {
                delegate.viewLikes(feed)
                return
            }
        }
    }
}
