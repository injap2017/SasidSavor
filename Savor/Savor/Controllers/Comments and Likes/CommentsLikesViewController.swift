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
    
    class func instance() -> CommentsLikesViewController {
        let storyboard = UIStoryboard.init(name: "CommentsLikes", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "commentsLikes") as! CommentsLikesViewController
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
}

// MARK: - TableView
extension CommentsLikesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewSelector {
        case .comments:
            return 3
        default:
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewSelector {
        case .comments:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentsPostDetailCell.identifier) as! CommentsPostDetailCell
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier) as! CommentCell
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: LikeCell.identifier) as! LikeCell
            return cell
        }
    }
}
