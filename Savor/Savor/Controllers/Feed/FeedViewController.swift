//
//  FeedViewController.swift
//  Savor
//
//  Created by Edgar Sia on 10/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import MagazineLayout
import KUIPopOver
import SVProgressHUD
import PullToRefreshKit

enum FeedViewMode: Int {
    case list
    case square
}

enum FeedSource: Int {
    case allPosts
    case friends
}

class FeedViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var squareCollectionView: UICollectionView!
    
    // MARK: - Properties
    var posts: [SSPost] = []
    var viewMode: FeedViewMode = .list {
        didSet {
            var frontView: UICollectionView
            switch viewMode {
            case .list:
                frontView = listCollectionView
            default:
                frontView = squareCollectionView
            }
            
            self.view.bringSubviewToFront(frontView)
            
            frontView.reloadData()
        }
    }
    var source: FeedSource = .allPosts {
        didSet {
            // try pull to refresh
            self.pullToRefreshAction()
        }
    }
    
    
    fileprivate var isLoadingPosts: Bool = false
    
    static let postsPerLoad: UInt = 20
    
    deinit {
        self.removeNotificationListeners()
    }
}

// MARK: - Lifecycle
extension FeedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        
        self.listenNotifications()
        
        self.source = .allPosts
    }
}

// MARK: - Functions
extension FeedViewController {
    
    func initView() {
        
        // uicollectionview
        self.listCollectionView.collectionViewLayout = MagazineLayout.init()
        self.listCollectionView.register(FeedListItem.nib, forCellWithReuseIdentifier: FeedListItem.identifier)
        self.listCollectionView.configRefreshHeader(container: self, action: pullToRefreshAction)
        
        self.squareCollectionView.collectionViewLayout = MagazineLayout.init()
        self.squareCollectionView.register(FeedSquareItem.nib, forCellWithReuseIdentifier: FeedSquareItem.identifier)
        self.squareCollectionView.configRefreshHeader(container: self, action: pullToRefreshAction)
        
        // set view mode init list
        self.viewMode = .list
        
        // set filter mode init all posts
        self.source = .allPosts
    }
    
    func listenNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(postNotificationHandler), name: Notification.Name.init(NewPostViewController.postNotification), object: nil)
    }
    
    func removeNotificationListeners() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Actions
extension FeedViewController {
    
    @IBAction func viewMode(_ sender: UIBarButtonItem, event: UIEvent) {
        // stop switch to other view mode while loading posts
        guard self.isLoadingPosts == false else {
            return
        }
        
        let viewController = FeedViewModePopUp.init()
        viewController.viewMode = viewMode
        viewController.delegate = self
        viewController.showPopover(barButtonItem: sender) {
            
        }
    }
    
    @IBAction func filterMode(_ sender: UIBarButtonItem, event: UIEvent) {
        // stop filtering while loading posts
        guard self.isLoadingPosts == false else {
            return
        }
        
        let viewController = FeedFilterModePopUp.init()
        viewController.source = source
        viewController.delegate = self
        viewController.showPopover(barButtonItem: sender) {
            
        }
    }
    
    @objc func postNotificationHandler() {
        // reload
        self.pullToRefreshAction()
    }
    
    @objc func pullToRefreshAction() {
        guard self.isLoadingPosts == false else {
            return
        }
        
        self.isLoadingPosts = true
        print("pull loading true")
        SVProgressHUD.show(withStatus: "Loading...")
        
        var getRecentPosts: (Double?, UInt, @escaping ([SSPost]) -> Void) -> Void
        if SSUser.isAuthenticated,
            source == .friends {
            getRecentPosts = APIs.Feed.getRecentPosts
        } else {
            getRecentPosts = APIs.Posts.getRecentPosts
        }
        getRecentPosts(nil, FeedViewController.postsPerLoad) { (posts) in
            
            let adding = posts.count
            
            self.posts = posts
            
            DispatchQueue.main.async {
                
                var collectionView: UICollectionView
                
                switch self.viewMode {
                case .list:
                    collectionView = self.listCollectionView
                case .square:
                    collectionView = self.squareCollectionView
                }
                
                collectionView.reloadData()
                collectionView.switchRefreshHeader(to: .normal(.none, 0.0))
                
                // add infinite scrolling
                if adding >= FeedViewController.postsPerLoad {
                    self.listCollectionView.configRefreshFooter(container: self, action: self.infiniteScrollingAction)
                    self.squareCollectionView.configRefreshFooter(container: self, action: self.infiniteScrollingAction)
                }
                
                print("pull loading false")
                self.isLoadingPosts = false
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @objc func infiniteScrollingAction() {
        guard self.isLoadingPosts == false else {
            return
        }
        
        guard let lastPostTimestamp = self.posts.last?.timestamp else {
            self.listCollectionView.switchRefreshFooter(to: .removed)
            self.squareCollectionView.switchRefreshFooter(to: .removed)
            return
        }
        
        self.isLoadingPosts = true
        print("scroll loading true")
        
        var getOldPosts: (Double, UInt, @escaping ([SSPost]) -> Void) -> Void
        if SSUser.isAuthenticated,
            source == .friends {
            getOldPosts = APIs.Feed.getOldPosts
        } else {
            getOldPosts = APIs.Posts.getOldPosts
        }
        getOldPosts(lastPostTimestamp, FeedViewController.postsPerLoad) { (posts) in
            
            let count = self.posts.count
            let adding = posts.count
            
            self.posts.append(contentsOf: posts)
            
            DispatchQueue.main.async {
                
                var collectionView: UICollectionView
                
                switch self.viewMode {
                case .list:
                    collectionView = self.listCollectionView
                case .square:
                    collectionView = self.squareCollectionView
                }
                
                collectionView.performBatchUpdates({
                    
                    var indexPaths: [IndexPath] = []
                    for i in (count..<count+adding) {
                        indexPaths.append(IndexPath.init(row: i, section: 0))
                    }
                    
                    collectionView.insertItems(at: indexPaths)
                    
                }) { (finished) in
                    
                    collectionView.switchRefreshFooter(to: .normal)
                    
                    if adding < FeedViewController.postsPerLoad {
                        self.listCollectionView.switchRefreshFooter(to: .removed)
                        self.squareCollectionView.switchRefreshFooter(to: .removed)
                    }
                    
                    self.isLoadingPosts = false
                    print("scroll loading false")
                }
            }
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
}

// MARK: - FeedListItem Delegate
extension FeedViewController: FeedListItemDelegate {
    
    func viewProfile(_ author: SSUser) {
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        ProfileViewController.syncData(userID: author.uid) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
    
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

// MARK: - UICollectionView
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case listCollectionView:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: FeedListItem.identifier, for: indexPath) as! FeedListItem
            let post = self.posts[indexPath.row]
            item.feed = post
            item.delegate = self
            return item
        default:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: FeedSquareItem.identifier, for: indexPath) as! FeedSquareItem
            let post = self.posts[indexPath.row]
            item.feed = post
            return item
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = self.posts[indexPath.row]
        self.didSelectFeedAction(post)
    }
}

// MARK: - MagazineLayout
extension FeedViewController: UICollectionViewDelegateMagazineLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeModeForItemAt indexPath: IndexPath) -> MagazineLayoutItemSizeMode {
        switch collectionView {
        case listCollectionView:
            let widthMode = MagazineLayoutItemWidthMode.fullWidth(respectsHorizontalInsets: true)
            let heightMode = MagazineLayoutItemHeightMode.static(height: 135)
            return MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode)
        default:
            let widthMode = MagazineLayoutItemWidthMode.thirdWidth
            let heightMode = MagazineLayoutItemHeightMode.dynamic
            return MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForHeaderInSectionAtIndex index: Int) -> MagazineLayoutHeaderVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForFooterInSectionAtIndex index: Int) -> MagazineLayoutFooterVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, visibilityModeForBackgroundInSectionAtIndex index: Int) -> MagazineLayoutBackgroundVisibilityMode {
        return .hidden
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, horizontalSpacingForItemsInSectionAtIndex index: Int) -> CGFloat {
        switch collectionView {
        case listCollectionView:
            return 0
        default:
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, verticalSpacingForElementsInSectionAtIndex index: Int) -> CGFloat {
        switch collectionView {
        case listCollectionView:
            return 0
        default:
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForSectionAtIndex index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsForItemsInSectionAtIndex index: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - FeedViewModePopUp Delgate
extension FeedViewController: FeedViewModePopUpDelegate {
    
    func didSelectViewMode(_ viewMode: FeedViewMode) {
        self.viewMode = viewMode
    }
}

// MARK: - FeedFilterModePopUp Delegate
extension FeedViewController: FeedFilterModePopUpDelegate {
    
    func didSelectSource(_ source: FeedSource) {
        self.source = source
    }
}
