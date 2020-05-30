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
import SVProgressHUD

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
    
    class func instance(user: SSUser, initialPosts: [SSPost], followings: [(SSUser, Int)], followers: [(SSUser, Int)]) -> ProfileViewController {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        viewController.user = user
        viewController.posts = initialPosts
        viewController.followings = followings
        viewController.followers = followers
        return viewController
    }
    
    class func syncData(userID: String, completion: @escaping (ProfileViewController) -> Void) {
        // load full user
        // load initial posts
        // load all followings
        // load all followers
        var user: SSUser?
        var initialPosts: [SSPost]?
        var allFollowings: [SSUser]?
        var allFollowers: [SSUser]?
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        APIs.Users.getUser(of: userID) { (_user) in
            user = _user
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        APIs.People.getRecentPosts(ofUser: userID, limit: postsPerLoad) { (posts) in
            initialPosts = posts
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        APIs.People.getFollowings(ofUser: userID) { (followings) in
            allFollowings = followings
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        APIs.People.getFollowers(ofUser: userID) { (followers) in
            allFollowers = followers
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            
            let dispatchGroup = DispatchGroup()
            
            var followingsPostCounts: [(Int, Int)] = []
            for (i, user) in allFollowings!.enumerated() {
                dispatchGroup.enter()
                APIs.People.getPostCount(ofUser: user.uid) { (postCount) in
                    followingsPostCounts.append((i, postCount))
                    dispatchGroup.leave()
                }
            }
            
            var followersPostCounts: [(Int, Int)] = []
            for (i, user) in allFollowers!.enumerated() {
                dispatchGroup.enter()
                APIs.People.getPostCount(ofUser: user.uid) { (postCount) in
                    followersPostCounts.append((i, postCount))
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                
                // sort by index
                followingsPostCounts.sort { (first, second) -> Bool in
                    return first.0 < second.0
                }
                
                followersPostCounts.sort { (first, second) -> Bool in
                    return first.0 < second.0
                }
                
                var allFollowingsPostCounts: [(SSUser, Int)] = []
                for followingPostCount in followingsPostCounts {
                    let user = allFollowings![followingPostCount.0]
                    let postCount = followingPostCount.1
                    allFollowingsPostCounts.append((user, postCount))
                }
                
                var allFollowersPostCounts: [(SSUser, Int)] = []
                for followerPostCount in followersPostCounts {
                    let user = allFollowers![followerPostCount.0]
                    let postCount = followerPostCount.1
                    allFollowersPostCounts.append((user, postCount))
                }
                
                // go to profile
                let viewController = ProfileViewController.instance(user: user!, initialPosts: initialPosts!, followings: allFollowingsPostCounts, followers: allFollowersPostCounts)
                
                completion(viewController)
            }
        }
    }
    
    func initView() {
        
        // header
        let width = UIScreen.main.bounds.size.width /* full screen width */
        let height = CGFloat(152)
        let frame = CGRect.init(x: 0, y: 0, width: width, height: height)
        let profileHeader = ProfileHeader.init(frame: frame)
        profileHeader.delegate = self
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
        let item = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(self.editAction))
        return item
    }
    
    @objc func editAction() {
        print("edit profile")
    }
    
    @objc func infiniteScrollingAction() {
        
    }
    
    func didSelectPostAction(_ post: SSPost) {
        guard let partialRestaurant = post.restaurant,
            let partialFood = post.food else {
            return
        }
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        FeedDetailViewController.syncData(Restaurant: partialRestaurant.restaurantID, Food: partialFood.foodID, viewSelector: .posts) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
    
    func didSelectFollowingAction(_ following: (SSUser, Int)) {
        
        let user = following.0
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        ProfileViewController.syncData(userID: user.uid) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
    
    func didSelectFollowerAction(_ follower: (SSUser, Int)) {
        
        let user = follower.0
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        ProfileViewController.syncData(userID: user.uid) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
}

// MARK: - UITableView
extension ProfileViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewSelector {
        case .posts:
            return self.posts.count
        case .following:
            return self.followings.count
        case .followers:
            return self.followers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewSelector {
        case .posts:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfilePostCell.identifier) as! ProfilePostCell
            cell.post = posts[indexPath.row]
            cell.delegate = self
            return cell
        case .following:
            let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.identifier) as! FollowCell
            let following = followings[indexPath.row]
            cell.user = following.0
            cell.postCount = following.1
            cell.delegate = self
            return cell
        case .followers:
            let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.identifier) as! FollowCell
            let follower = followers[indexPath.row]
            cell.user = follower.0
            cell.postCount = follower.1
            cell.delegate = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewSelector {
        case .posts:
            tableView.deselectRow(at: indexPath, animated: false)
            let post = self.posts[indexPath.row]
            self.didSelectPostAction(post)
        case .following:
            tableView.deselectRow(at: indexPath, animated: false)
            let following = self.followings[indexPath.row]
            self.didSelectFollowingAction(following)
            break
        case .followers:
            tableView.deselectRow(at: indexPath, animated: false)
            let follower = self.followers[indexPath.row]
            self.didSelectFollowerAction(follower)
            break
        }
    }
}

// MARK: - ProfilePostCell Delegate
extension ProfileViewController: ProfilePostCellDelegate {
    func viewComments(_ post: SSPost) {
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        CommentsLikesViewController.syncData(Post: post, viewSelector: .comments) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
    
    func viewLikes(_ post: SSPost) {
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        CommentsLikesViewController.syncData(Post: post, viewSelector: .likes) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
    
    func addComment(_ post: SSPost) {
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        CommentsLikesViewController.syncData(Post: post, viewSelector: .comments) { (viewController) in
            SVProgressHUD.dismiss()
            
            viewController.openWithKeyboardActive = true
            
            self.navigationController?.pushViewController(viewController)
        }
    }
}

// MARK: - ProfileHeader Delegate
extension ProfileViewController: ProfileHeaderDelegate {
    
    func followed() {
        // load me
        var user: SSUser?
        var postCount: Int?
        
        SVProgressHUD.show(withStatus: "Following...")
        
        let dispatchGroup = DispatchGroup.init()
        
        dispatchGroup.enter()
        APIs.Users.getUser(of: SSUser.authCurrentUser.uid) { (_user) in
            user = _user
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        APIs.People.getPostCount(ofUser: SSUser.authCurrentUser.uid) { (_postCount) in
            postCount = _postCount
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            let follower: (SSUser, Int) = (user!, postCount!)
            
            self.followers.insert(follower, at: 0)
            
            if self.viewSelector == .followers {
                let indexPath = IndexPath.init(row: 0, section: 0)
                
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func unfollowed() {
        let index = self.followers.firstIndex { (follower) -> Bool in
            return follower.0.uid == SSUser.authCurrentUser.uid
        }
        
        if let index = index {
            self.followers.remove(at: index)
            
            if self.viewSelector == .followers {
                let indexPath = IndexPath.init(row: index, section: 0)
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
}

// MARK: - FollowCell Delegate
extension ProfileViewController: FollowCellDelegate {
    
    func followed(_ data: (SSUser, Int)) {
        if isItMe() {
            self.followings.insert(data, at: 0)
        }
    }
    
    func unfollowed(_ data: (SSUser, Int)) {
        if isItMe() {
            let index = self.followings.firstIndex { (following) -> Bool in
                return data.0.uid == following.0.uid
            }
            
            if let index = index {
                self.followings.remove(at: index)
                
                if self.viewSelector == .following {
                    let indexPath = IndexPath.init(row: index, section: 0)
                    
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        }
    }
}
