//
//  ProfileViewController.swift
//  Savor
//
//  Created by Edgar Sia on 5/26/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import ESPullToRefresh
import Firebase

enum FollowStatus: Int {
    case follow /* you don't follow him/her, able to follow */
    case unfollow /* you are following him/her, able to unfollow */
    case disabled /* you are not able to do any action */
}

enum ProfileViewSelector: Int {
    case posts
    case following
    case followers
}

class ProfileViewController: UITableViewController {
    
    // MARK: - Properties
    var user: SSUser!
    
    var posts: [SSPost] = []
    var followings: [(SSUser, Int)] = []
    var followers: [(SSUser, Int)] = []
    
    var profileHeader: ProfileHeader?
    
    var viewSelector: ProfileViewSelector = .posts {
        didSet {
            // refresh tableview to see the view parts
            self.tableView?.reloadData()
            // add infinite scrolling
            if viewSelector == .posts {
                self.tableView?.es.addInfiniteScrolling(handler: infiniteScrollingAction)
            } else {
                self.tableView?.es.removeRefreshFooter()
            }
        }
    }
    
    static let postsPerLoad: UInt = 20
    
    var handle: AuthStateDidChangeListenerHandle?
    
    deinit {
        removeObservers()
    }
}

// MARK: - Lifecycle
extension ProfileViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        self.observe()
    }
}

// MARK: - Functions
extension ProfileViewController {
    
    class func instance() -> ProfileViewController {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        viewController.navigationItem.rightBarButtonItem = viewController.isItMe() ? viewController.editBarButtonItem() : nil
        return viewController
    }
    
    class func syncData(userID: String, completion: @escaping (ProfileViewController) -> Void) {
        // load full user
        // load initial posts ids
        // load all followings ids
        // load all followers ids
        var user: SSUser?
        var initialPosts: [SSPost]?
        var allFollowingIDs: [String]?
        var allFollowerIDs: [String]?
        
        APIs.Users.getUser(of: userID) { (_user) in
            user = _user
        }
        
        APIs.People.getFollowers(ofUser: userID) { (followerIDs) in
            
        }
        
        APIs.People.getFollowings(ofUser: userID) { (followingIDs) in
            
        }
        
        APIs.People.getRecentPosts(ofUser: userID, limit: postsPerLoad) { (posts) in
            
        }
    }
    
    func initView() {
        
        // header
        let width = UIScreen.main.bounds.size.width /* full screen width */
        let height = CGFloat(152)
        let frame = CGRect.init(x: 0, y: 0, width: width, height: height)
        let profileHeader = ProfileHeader.init(frame: frame)
        profileHeader.user = self.user
        profileHeader.segmentedControl.selectedSegmentIndex = viewSelector.rawValue
        profileHeader.segmentedControl.addTarget(self, action: #selector(viewSelectorValueChanged(_:)), for: .valueChanged)
        self.tableView.tableHeaderView = profileHeader
        self.profileHeader = profileHeader
        
        // cell
        self.tableView.register(ProfilePostCell.nib, forCellReuseIdentifier: ProfilePostCell.identifier)
        self.tableView.register(FollowCell.nib, forCellReuseIdentifier: FollowCell.identifier)
        
        // footer
        self.tableView.tableFooterView = UIView.init()
        
        // viewSelector
        self.viewSelectorValueChanged(profileHeader.segmentedControl)
    }
    
    func observe() {
        // auth state listner to change title and add Edit barbuttonitem
        self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if SSUser.isAuthenticated,
                self.isItMe() {
                self.title = "My Profile"
                self.navigationItem.rightBarButtonItem = self.editBarButtonItem()
            } else {
                self.title = self.user.fullname
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    func removeObservers() {
        // remove auth state change listener
        Auth.auth().removeStateDidChangeListener(self.handle!)
    }
    
    func isItMe() -> Bool {
        if SSUser.isAuthenticated,
            SSUser.authCurrentUser.uid == user.uid {
            return true
        }
        return false
    }
}

// MARK: - Actions
extension ProfileViewController {
    
    @objc func viewSelectorValueChanged(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.viewSelector = .posts
        case 1:
            self.viewSelector = .following
        default:
            self.viewSelector = .followers
        }
    }
    
    func editBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.editAction))
        return item
    }
    
    @objc func editAction() {
        
    }
    
    @objc func pullToRefreshAction() {
    }
    
    @objc func infiniteScrollingAction() {
    }
}
