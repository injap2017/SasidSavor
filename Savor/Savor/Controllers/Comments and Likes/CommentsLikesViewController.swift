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
import IQKeyboardManagerSwift

enum CommentsLikesViewSelector: Int {
    case comments
    case likes
}

class CommentsLikesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var post: SSPost?
    var allComments: [SSComment]?
    var allLikes: [SSLike]?
    
    var commentsPostDetailCell: CommentsPostDetailCell?
    var commentCount: Int {
        get {
            return commentsPostDetailCell?.commentCount ?? 0
        }
    }
    
    var segmentedControl: UISegmentedControl!
    
    var viewSelector: CommentsLikesViewSelector = .comments {
        didSet {
            // refresh tableview to see the view parts
            self.tableView?.reloadData()
        }
    }
    
    var openWithKeyboardActive: Bool = false
    
    // inputbar accessory view
    var inputBar: InputBarAccessoryView!
    var keyboardManager: KeyboardManager!
    
    // auth handle to hide/show inputbar accessory view
    var handle: AuthStateDidChangeListenerHandle?
    
    deinit {
        removeObservers()
    }
}

// MARK: - Lifecycle
extension CommentsLikesViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        self.observe()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // one time keyboard active if true
        if openWithKeyboardActive,
            let inputBar = self.inputBar {
            inputBar.inputTextView.becomeFirstResponder()
            self.openWithKeyboardActive = false
        }
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
                
                // sort by timestamp
                let sortedCommentsFull = commentsFull.sorted { (first, second) -> Bool in
                    return first.timestamp > second.timestamp
                }
                
                let sortedLikesFull = likesFull.sorted { (first, second) -> Bool in
                    return first.timestamp > second.timestamp
                }
                
                // go to comments and likes
                let viewController = CommentsLikesViewController.instance(post: post, allComments: sortedCommentsFull, allLikes: sortedLikesFull)
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
        
        // iqkeyboardmanager disable distance handling to control distance between inputaccessoryview and keyboard
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(CommentsLikesViewController.self)
    }
    
    func observe() {
        // auth state listner to hide/show input accessory view
        self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if SSUser.isAuthenticated,
                self.viewSelector == .comments {
                self.setInputBarAccessoryViewIfNoExist()
            } else {
                self.removeInputBarAccessoryView()
            }
        }
    }
    
    func removeObservers() {
        // remove auth state change listener
        Auth.auth().removeStateDidChangeListener(self.handle!)
    }
    
    func setInputBarAccessoryViewIfNoExist() {
        
        // return if exist
        if self.inputBar != nil,
            self.keyboardManager != nil {
            return
        }
        
        // set inputbar accessory view
        self.inputBar = InputBarAccessoryView()
        self.inputBar.inputTextView.keyboardType = .twitter
        self.inputBar.inputTextView.placeholder = "Add a Comment..."
        self.inputBar.sendButton.title = "Post"
        self.inputBar.delegate = self
        self.view.addSubview(inputBar)
        
        self.keyboardManager = KeyboardManager()
        self.keyboardManager.bind(inputAccessoryView: inputBar)
        self.keyboardManager.bind(to: tableView)
    }
    
    func removeInputBarAccessoryView() {
        if let inputBar = self.inputBar {
            inputBar.removeFromSuperview()
        }
        self.inputBar = nil
        self.keyboardManager = nil
    }
    
    func isCurrentUserAbleToEditThisComment(_ comment: SSComment, ofPost post: SSPost) -> Bool {
        if SSUser.isAuthenticated {
            if SSUser.authCurrentUser.uid == post.author?.uid {
                return true
            } else if SSUser.authCurrentUser.uid == comment.author?.uid {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Actions
extension CommentsLikesViewController {
    
    @objc func viewSelectorValueChanged(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.viewSelector = .comments
            if SSUser.isAuthenticated { setInputBarAccessoryViewIfNoExist() }
        } else {
            self.viewSelector = .likes
            self.removeInputBarAccessoryView()
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
    
    func didPostComment(withText text: String, at timestamp: Double) {
        guard let post = self.post else {
            return
        }
        
        SVProgressHUD.show(withStatus: "Posting Comment...")
        
        // load current user
        APIs.Users.getUser(of: SSUser.authCurrentUser.uid) { (user) in
            
            // post comment
            let commentID = APIs.Comments.commented(postID: post.postID, text: text, timestamp: timestamp)
            APIs.People.commented(postID: post.postID, commentID: commentID)
            APIs.Comments.setCommentCount(of: post.postID, to: self.commentCount+1)
            
            // append cache
            let comment = SSComment.init(commentID: commentID, text: text, author: user, timestamp: timestamp)
            self.allComments!.insert(comment, at: 0)
            
            // update tableview
            let indexPath = IndexPath.init(row: 1, section: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            
            SVProgressHUD.dismiss()
        }
    }
    
    func didDeleteComment(_ comment: SSComment, at indexPath: IndexPath) {
        guard let post = self.post else {
            return
        }
        
        // delete comment
        APIs.Comments.uncommented(postID: post.postID, commentID: comment.commentID)
        APIs.People.uncommented(postID: post.postID, commentID: comment.commentID)
        APIs.Comments.setCommentCount(of: post.postID, to: self.commentCount-1)
        
        // remove cache
        self.allComments!.remove(at: indexPath.row-1)
        
        // update tableview
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
    }
}

// MARK: - TableView
extension CommentsLikesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewSelector {
        case .comments:
            return 1 + (self.allComments?.count ?? 0)
        default:
            return self.allLikes?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewSelector {
        case .comments:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentsPostDetailCell.identifier) as! CommentsPostDetailCell
                cell.post = post
                cell.delegate = self
                self.commentsPostDetailCell = cell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch viewSelector {
        case .comments:
            if indexPath.row == 0 {
                return false
            }
            let comment = allComments![indexPath.row-1]
            return isCurrentUserAbleToEditThisComment(comment, ofPost: post!)
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let comment = allComments![indexPath.row-1]
            self.didDeleteComment(comment, at: indexPath)
        }
    }
}

// MARK: - CommentsPostDetailCell Delegate, CommentCell Delegate
extension CommentsLikesViewController: CommentsPostDetailCellDelegate, CommentCellDelegate {
    
    func viewProfile(_ author: SSUser) {
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        ProfileViewController.syncData(userID: author.uid) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
}

// MARK: - InputBarAccessoryView Delegate
extension CommentsLikesViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = String()
        inputBar.inputTextView.resignFirstResponder()
        
        let timestamp = Date().timeIntervalSince1970
        self.didPostComment(withText: text, at: timestamp)
    }
}
