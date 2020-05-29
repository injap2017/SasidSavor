//
//  ProfilePostCell.swift
//  Savor
//
//  Created by Edgar Sia on 5/26/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos
import Firebase

protocol ProfilePostCellDelegate {
    func viewComments(_ post: SSPost)
    func viewLikes(_ post: SSPost)
    func addComment(_ post: SSPost)
}

class ProfilePostCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postPhotoImageView: UIImageView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var restaurantNameAddressLabel: UILabel!
    
    @IBOutlet weak var postScore: CosmosView!
    
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var commentsImageView: UIImageView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "ProfilePostCell"
    static let nib = UINib.init(nibName: "ProfilePostCell", bundle: nil)
    
    var delegate: ProfilePostCellDelegate?
    
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
    
    var post: SSPost? {
        didSet {
            postPhotoImageView.image = UIImage.init(named: "image-off-outline")
            
            postTitleLabel.text = nil
            postDescriptionLabel.text = "\n\n" /*2 blank lines*/
            restaurantNameAddressLabel.text = nil
            
            postScore.rating = 0.0
            
            postDateLabel.text = nil
            
            likeCount = 0
            liked = false
            isLikeActionAvailable = false
            
            commentCount = 0
            commented = false
            isCommentActionAvailable = false
            
            if let post = self.post {
                
                if let photos = post.photos,
                    let first = photos.first,
                    let fullPath = first["full_url"],
                    let fullURL = URL.init(string: fullPath) {
                    postPhotoImageView.sd_setImage(with: fullURL)
                }
                
                postTitleLabel.text = post.food?.name
                postDescriptionLabel.text = post.text
                restaurantNameAddressLabel.text = post.restaurant?.address()
                
                postScore.rating = post.rating // colour by score
                
                let timestampDate = Date(timeIntervalSince1970: post.timestamp)
                postDateLabel.text = SavorData.Accessories.timestampText(timestampDate)
                
                // below install all observers
                likeCountHandle = APIs.Likes.observeLikeCount(of: post.postID) { (count) in
                    self.likeCount = count
                }
                
                commentCountHandle = APIs.Comments.observeCommentCount(of: post.postID) { (count) in
                    self.commentCount = count
                }
                
                handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                    if SSUser.isAuthenticated {
                        self.userID = SSUser.authCurrentUser.uid
                        self.likedHandle = APIs.People.observeLiked(ofPost: post.postID, fromUser: self.userID!) { (liked) in
                            self.isLikeActionAvailable = true
                            self.liked = liked
                        }
                        self.commentedHandle = APIs.People.observeCommented(ofPost: post.postID, fromUser: self.userID!) { (commented) in
                            self.isCommentActionAvailable = true
                            self.commented = commented
                        }
                    } else {
                        if let likedHandle = self.likedHandle, let userID = self.userID {
                            APIs.People.removeLikedObserver(ofPost: post.postID, fromUser: userID, withHandle: likedHandle)
                            self.likedHandle = nil
                            
                            self.isLikeActionAvailable = false
                            self.liked = false
                        }
                        if let commentedHandle = self.commentedHandle, let userID = self.userID {
                            APIs.People.removeCommentedObserver(ofPost: post.postID, fromUser: userID, withHandle: commentedHandle)
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
extension ProfilePostCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        /* iOS dequeueReusableCell returns previus created and used cell which still has lived handles, hence we have to release the handles before using it so that prevent listen handle duplicated into the ui elements */
        self.removeAllObservers()
    }
}

// MARK: - Functions
extension ProfilePostCell {
    
    func removeAllObservers() {
        
        if let post = self.post {
            if let likeCountHandle = self.likeCountHandle {
                APIs.Likes.removeLikeCountObserver(of: post.postID, withHandle: likeCountHandle)
                self.likeCountHandle = nil
                
                self.likeCount = 0
            }
            if let commentCountHandle = self.commentCountHandle {
                APIs.Comments.removeCommentCountObserver(of: post.postID, withHandle: commentCountHandle)
                self.commentCountHandle = nil
                
                self.commentCount = 0
            }
            if let likedHandle = self.likedHandle, let userID = self.userID {
                APIs.People.removeLikedObserver(ofPost: post.postID, fromUser: userID, withHandle: likedHandle)
                self.likedHandle = nil
                
                self.isLikeActionAvailable = false
                self.liked = false
            }
            if let commentedHandle = self.commentedHandle, let userID = self.userID {
                APIs.People.removeCommentedObserver(ofPost: post.postID, fromUser: userID, withHandle: commentedHandle)
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
extension ProfilePostCell {
    
    @IBAction func commentsLikes(_ sender: UIButton) {
        if let post = self.post,
            let delegate = self.delegate {
            if self.commentCount > 0 {
                delegate.viewComments(post)
                return
            }
            if self.likeCount > 0 {
                delegate.viewLikes(post)
                return
            }
        }
    }
    
    @IBAction func like(_ sender: UIButton) {
        if let post = self.post,
            isLikeActionAvailable {
            sender.isEnabled = false
            if self.liked {
                APIs.Likes.unliked(postID: post.postID)
                APIs.People.unliked(postID: post.postID)
                APIs.Likes.setLikeCount(of: post.postID, to: self.likeCount-1)
            } else {
                let timestamp = Date().timeIntervalSince1970
                APIs.Likes.liked(postID: post.postID, timestamp: timestamp)
                APIs.People.liked(postID: post.postID)
                APIs.Likes.setLikeCount(of: post.postID, to: self.likeCount+1)
            }
            sender.isEnabled = true
        }
    }
    
    @IBAction func comment(_ sender: UIButton) {
        if let post = self.post,
            isCommentActionAvailable,
            let delegate = self.delegate {
            delegate.addComment(post)
        }
    }
}
