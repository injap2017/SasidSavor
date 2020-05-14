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
import Firebase

protocol FeedListItemDelegate {
    func viewProfile(_ author: SSUser)
    func viewComments(_ post: SSPost)
    func viewLikes(_ post: SSPost)
    func addComment(_ post: SSPost)
}

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
    
    var delegate: FeedListItemDelegate?
    
    private var handle: AuthStateDidChangeListenerHandle?
    private var userID: String?
    
    private var likeCountHandle: UInt?
    private var likedHandle: UInt?
    
    var isLikeActionAvailable: Bool = false {
        didSet {
            likeButton.isHidden = !isLikeActionAvailable
        }
    }
    
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
            likeButton.setImage(liked ? UIImage.init(named: "heart-red") : UIImage.init(named: "heart-outline-gray"), for: .normal)
            likesImageView.image = liked ? UIImage.init(named: "heart-red") : UIImage.init(named: "heart-gray")
        }
    }
    
    private var commentCountHandle: UInt?
    private var commentedHandle: UInt?
    
    var isCommentActionAvailable: Bool = false {
        didSet {
            commentButton.isHidden = !isCommentActionAvailable
        }
    }
    
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
            commentButton.setImage(commented ? UIImage.init(named: "chat-green") : UIImage.init(named: "chat-outline-gray"), for: .normal)
            commentsImageView.image = commented ? UIImage.init(named: "chat-green") : UIImage.init(named: "chat-gray")
        }
    }
    
    var feed: SSPost? {
        didSet {
            postPhotoImageView.image = UIImage.init(named: "image-off-outline")
            
            postTitleLabel.text = nil
            postDescriptionLabel.text = nil
            restaurantNameAddressLabel.text = nil
            
            postScore.rating = 0.0
            userNameButton.setTitle(nil, for: .normal)
            
            postDateLabel.text = nil
            
            likeCount = 0
            liked = false
            isLikeActionAvailable = false
            
            commentCount = 0
            commented = false
            isCommentActionAvailable = false
            
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
                
                // below install all observers
                likeCountHandle = APIs.Likes.observeLikeCount(of: feed.postID) { (count) in
                    self.likeCount = count
                }
                
                commentCountHandle = APIs.Comments.observeCommentCount(of: feed.postID) { (count) in
                    self.commentCount = count
                }
                
                handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if SavorData.FireBase.isAuthenticated {
                        self.userID = SSUser.currentUser().uid
                        self.likedHandle = APIs.People.observeLiked(ofPost: feed.postID, fromUser: self.userID!) { (liked) in
                            self.isLikeActionAvailable = true
                            self.liked = liked
                        }
                        self.commentedHandle = APIs.People.observeCommented(ofPost: feed.postID, fromUser: self.userID!) { (commented) in
                            self.isCommentActionAvailable = true
                            self.commented = commented
                        }
                    } else {
                        if let likedHandle = self.likedHandle, let userID = self.userID {
                            APIs.People.removeLikedObserver(ofPost: feed.postID, fromUser: userID, withHandle: likedHandle)
                            self.likedHandle = nil
                            
                            self.isLikeActionAvailable = false
                            self.liked = false
                        }
                        if let commentedHandle = self.commentedHandle, let userID = self.userID {
                            APIs.People.removeCommentedObserver(ofPost: feed.postID, fromUser: userID, withHandle: commentedHandle)
                            self.commentedHandle = nil
                            
                            self.isCommentActionAvailable = false
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
extension FeedListItem {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        /* iOS dequeueReusableCell returns previus created and used cell which still has lived handles, hence we have to release the handles before using it so that prevent listen handle duplicated into the ui elements */
        self.removeAllObservers()
    }
}

// MARK: - Functions
extension FeedListItem {
    
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
                
                self.isLikeActionAvailable = false
                self.liked = false
            }
            if let commentedHandle = self.commentedHandle, let userID = self.userID {
                APIs.People.removeCommentedObserver(ofPost: feed.postID, fromUser: userID, withHandle: commentedHandle)
                self.commentedHandle = nil
                
                self.isCommentActionAvailable = false
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
extension FeedListItem {
    
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
    
    @IBAction func like(_ sender: UIButton) {
        if let feed = self.feed,
            isLikeActionAvailable {
            sender.isEnabled = false
            if self.liked {
                APIs.Likes.unliked(postID: feed.postID)
                APIs.People.unliked(postID: feed.postID)
                APIs.Likes.setLikeCount(of: feed.postID, to: self.likeCount-1)
            } else {
                let timestamp = Date().timeIntervalSince1970
                APIs.Likes.Liked(postID: feed.postID, timestamp: timestamp)
                APIs.People.Liked(postID: feed.postID)
                APIs.Likes.setLikeCount(of: feed.postID, to: self.likeCount+1)
            }
            sender.isEnabled = true
        }
    }
    
    @IBAction func comment(_ sender: UIButton) {
        if let feed = self.feed,
            isCommentActionAvailable,
            let delegate = self.delegate {
            delegate.addComment(feed)
        }
        
/* Legacy code for adding comments
        if let feed = self.feed,
            isCommentActionAvailable {
            sender.isEnabled = false
            let timestamp = Date().timeIntervalSince1970
            let commentID = APIs.Comments.commented(postID: feed.postID, text: "I love this", timestamp: timestamp)
            APIs.People.commented(postID: feed.postID, commentID: commentID)
            APIs.Comments.setCommentCount(of: feed.postID, to: self.commentCount+1)
            sender.isEnabled = true
        }*/
    }
}
