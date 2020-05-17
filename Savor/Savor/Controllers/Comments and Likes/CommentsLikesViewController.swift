//
//  CommentsLikesViewController.swift
//  Savor
//
//  Created by Edgar Sia on 5/5/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import SVProgressHUD
import InputBarAccessoryView
import Firebase

enum CommentsLikesViewSelector: Int {
    case comments
    case likes
}

class CommentsLikesViewController: UITableViewController {
    
    // MARK: - Properties
    var post: SSPost?
    var allComments: [SSComment]?
    var allLikes: [SSLike]?
    
    var segmentedControl: UISegmentedControl!
    
    var viewSelector: CommentsLikesViewSelector = .comments {
        didSet {
            // refresh tableview to see the view parts
            self.tableView?.reloadData()
        }
    }
}

// MARK: - Lifecycle
extension CommentsLikesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension CommentsLikesViewController {
    
    class func instance(post: SSPost, allComments: [SSComment], allLikes: [SSLike]) -> CommentsLikesViewController {
        let storyboard = UIStoryboard.init(name: "CommentsLikes", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "commentsLikes") as! CommentsLikesViewController
        viewController.post = post
        viewController.allComments = allComments
        viewController.allLikes = allLikes
        return viewController
    }
    
    class func syncData(Post post: SSPost, viewSelector: CommentsLikesViewSelector, completion: @escaping (CommentsLikesViewController) -> Void) {
        // load all comments
        // load all likes
        var comments: [(String, String, Double)]?
        var likes: [(String, Double)]?
        
        let dispatchGroup = DispatchGroup.init()
        
        dispatchGroup.enter()
        APIs.Comments.getComments(ofPost: post.postID) { (_comments) in
            comments = _comments
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        APIs.Likes.getLikes(ofPost: post.postID) { (_likes) in
            likes = _likes
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            // load all commenters
            // load all comment collections
            var commenters: [(Int, SSUser)] = []
            var commentCollections: [(Int, SSCommentCollectionRecord)] = []
            
            let dispatchGroup = DispatchGroup.init()
            
            for (i, comment) in comments!.enumerated() {
                
                dispatchGroup.enter()
                APIs.CommentCollection.getCommentCollectionRecord(of: comment.1) { (commentCollectionRecord) in
                    commentCollections.append((i, commentCollectionRecord))
                    
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                APIs.Users.getUser(of: comment.0) { (user) in
                    commenters.append((i, user))
                    
                    dispatchGroup.leave()
                }
            }
            
            // load all likers
            var likers: [(Int, SSUser)] = []
            for (i, like) in likes!.enumerated() {
                
                dispatchGroup.enter()
                APIs.Users.getUser(of: like.0) { (user) in
                    likers.append((i, user))
                    
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // compound all comments
                // compound all likes
                var commentsFull: [SSComment] = []
                var likesFull: [SSLike] = []
                
                for commentCollection in commentCollections {
                    let commentCollectionRecord = commentCollection.1
                    let commenter = commenters[commentCollection.0]
                    let timestamp = comments![commentCollection.0].2
                    let commentFull = SSComment.init(commentID: commentCollectionRecord.commentID,
                                                 text: commentCollectionRecord.text,
                                                 author: commenter.1,
                                                 timestamp: timestamp)
                    commentsFull.append(commentFull)
                }
                
                for liker in likers {
                    let timestamp = likes![liker.0].1
                    let like = SSLike.init(author: liker.1, timestamp: timestamp)
                    likesFull.append(like)
                }
                
                // go to comments and likes
                let viewController = CommentsLikesViewController.instance(post: post, allComments: commentsFull, allLikes: likesFull)
                viewController.viewSelector = viewSelector

                completion(viewController)
            }
        }
    }
    
    func initView() {
        // uisegmentedcontrol
        self.segmentedControl = UISegmentedControl.init(items: ["Comments", "Likers"])
        self.segmentedControl.selectedSegmentIndex = viewSelector.rawValue
        self.segmentedControl.addTarget(self, action: #selector(viewSelectorValueChanged(_:)), for: .valueChanged)
        
        // title
        self.navigationItem.titleView = segmentedControl
        
        // cell
        self.tableView.register(CommentsPostDetailCell.nib, forCellReuseIdentifier: CommentsPostDetailCell.identifier)
        self.tableView.register(CommentCell.nib, forCellReuseIdentifier: CommentCell.identifier)
        self.tableView.register(LikeCell.nib, forCellReuseIdentifier: LikeCell.identifier)
        
        // footer
        self.tableView.tableFooterView = UIView.init()
    }
}

// MARK: - Actions
extension CommentsLikesViewController {
    
    @objc func viewSelectorValueChanged(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.viewSelector = .comments
        } else {
            self.viewSelector = .likes
        }
    }
    
    func didSelectFeedAction(_ feed: SSPost) {
        guard let partialRestaurant = feed.restaurant,
            let partialFood = feed.food else {
            return
        }
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        FeedDetailViewController.syncData(Restaurant: partialRestaurant.restaurantID, Food: partialFood.foodID, viewSelector: .posts) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
    
    func didSelectLikeAction(_ like: SSLike) {
        // go to user profile
    }
}

// MARK: - TableView
extension CommentsLikesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewSelector {
        case .comments:
            return 1 + (self.allComments?.count ?? 0)
        default:
            return self.allLikes?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewSelector {
        case .comments:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentsPostDetailCell.identifier) as! CommentsPostDetailCell
                cell.post = post
                cell.delegate = self
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier) as! CommentCell
            cell.comment = allComments![indexPath.row-1]
            cell.delegate = self
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: LikeCell.identifier) as! LikeCell
            cell.like = allLikes![indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewSelector {
        case .comments:
            if indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: false)
                self.didSelectFeedAction(post!)
            }
        default:
            tableView.deselectRow(at: indexPath, animated: false)
            let like = allLikes![indexPath.row]
            self.didSelectLikeAction(like)
        }
    }
}

// MARK: - CommentsPostDetailCell Delegate, CommentCell Delegate
extension CommentsLikesViewController: CommentsPostDetailCellDelegate, CommentCellDelegate {
    
    func viewProfile(_ author: SSUser) {
        
    }
}
