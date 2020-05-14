//
//  CommentsPostDetailCell.swift
//  Savor
//
//  Created by Edgar Sia on 5/13/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos
import Firebase

protocol CommentsPostDetailCellDelegate {
    func viewProfile(_ author: SSUser)
}

class CommentsPostDetailCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postPhotoImageView: UIImageView!
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var restaurantNameAddressLabel: UILabel!
    
    @IBOutlet weak var postScore: CosmosView!
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var commentsImageView: UIImageView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "CommentsPostDetailCell"
    static let nib = UINib.init(nibName: "CommentsPostDetailCell", bundle: nil)
    
    var delegate: CommentsPostDetailCellDelegate?
    
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
    
    var post: SSPost? {
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
            
            commentCount = 0
            commented = false
            
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
                userNameButton.setTitle(post.author?.fullname, for: .normal)
                
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
                    if SavorData.FireBase.isAuthenticated {
                        self.userID = SSUser.currentUser().uid
                        self.likedHandle = APIs.People.observeLiked(ofPost: post.postID, fromUser: self.userID!) { (liked) in
                            self.liked = liked
                        }
                        self.commentedHandle = APIs.People.observeCommented(ofPost: post.postID, fromUser: self.userID!) { (commented) in
                            self.commented = commented
                        }
                    } else {
                        if let likedHandle = self.likedHandle, let userID = self.userID {
                            APIs.People.removeLikedObserver(ofPost: post.postID, fromUser: userID, withHandle: likedHandle)
                            self.likedHandle = nil
                            
                            self.liked = false
                        }
                        if let commentedHandle = self.commentedHandle, let userID = self.userID {
                            APIs.People.removeCommentedObserver(ofPost: post.postID, fromUser: userID, withHandle: commentedHandle)
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
extension CommentsPostDetailCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        /* iOS dequeueReusableCell returns previus created and used cell which still has lived handles, hence we have to release the handles before using it so that prevent listen handle duplicated into the ui elements */
        self.removeAllObservers()
    }
}

// MARK: - Functions
extension CommentsPostDetailCell {
    
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
                
                self.liked = false
            }
            if let commentedHandle = self.commentedHandle, let userID = self.userID {
                APIs.People.removeCommentedObserver(ofPost: post.postID, fromUser: userID, withHandle: commentedHandle)
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
extension CommentsPostDetailCell {
    
    @IBAction func user(_ sender: UIButton) {
        if let post = self.post,
            let delegate = self.delegate,
            let user = post.author {
            delegate.viewProfile(user)
        }
    }
}
