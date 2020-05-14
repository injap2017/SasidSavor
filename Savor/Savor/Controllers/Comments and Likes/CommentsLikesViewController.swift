//
//  CommentsLikesViewController.swift
//  Savor
//
//  Created by Edgar Sia on 5/5/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

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
        // go to feed details, same code here with feed view
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
            cell.comment = allComments![indexPath.row]
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
            self.didSelectFeedAction(post!)
        default:
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
