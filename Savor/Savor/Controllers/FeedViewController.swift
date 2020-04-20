//
//  FeedViewController.swift
//  Savor
//
//  Created by Edgar Sia on 10/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import MagazineLayout
import FTPopOverMenu_Swift
import SVProgressHUD
import ESPullToRefresh

enum FeedsViewMode: Int {
    case list
    case square
}

class FeedViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var squareCollectionView: UICollectionView!
    
    // MARK: - Properties
    var posts: [SSPost] = []
    var viewMode: FeedsViewMode = .list {
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
        
        self.pullToRefreshAction()
    }
}

// MARK: - Functions
extension FeedViewController {
    
    func initView() {
        
        // uicollectionview
        self.listCollectionView.collectionViewLayout = MagazineLayout.init()
        self.listCollectionView.register(FeedListItem.nib, forCellWithReuseIdentifier: FeedListItem.identifier)
        self.listCollectionView.es.addPullToRefresh(handler: pullToRefreshAction)
        self.listCollectionView.es.addInfiniteScrolling(handler: infiniteScrollingAction)
        
        self.squareCollectionView.collectionViewLayout = MagazineLayout.init()
        self.squareCollectionView.register(FeedSquareItem.nib, forCellWithReuseIdentifier: FeedSquareItem.identifier)
        self.squareCollectionView.es.addPullToRefresh(handler: pullToRefreshAction)
        self.squareCollectionView.es.addInfiniteScrolling(handler: infiniteScrollingAction)
        
        // view mode popover
        self.configureFTPopOverMenu()
        
        // set view mode init list
        self.viewMode = .list
    }
    
    func configureFTPopOverMenu() {
        
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
        
        FTPopOverMenu.showForEvent(event: event, with: ["List", "Gallery"], menuImageArray: ["format-list-bulleted-square", "view-grid"], done: { (selectedIndex) in
            
            switch selectedIndex {
            case FeedsViewMode.list.rawValue:
                self.viewMode = .list
            default:
                self.viewMode = .square
            }
            
        }) {
            
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
        APIs.Posts.getRecentPosts(start: nil, limit: FeedViewController.postsPerLoad) { (posts) in
            
            self.posts = posts
            
            DispatchQueue.main.async {
                
                switch self.viewMode {
                case .list:
                    self.listCollectionView.reloadData()
                    self.listCollectionView.es.stopPullToRefresh()
                case .square:
                    self.squareCollectionView.reloadData()
                    self.squareCollectionView.es.stopPullToRefresh()
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
            switch self.viewMode {
            case .list:
                self.listCollectionView.es.stopLoadingMore()
            case .square:
                self.squareCollectionView.es.stopLoadingMore()
            }
            return
        }
        
        self.isLoadingPosts = true
        print("scroll loading true")
        
        APIs.Posts.getOldPosts(start: lastPostTimestamp, limit: FeedViewController.postsPerLoad) { (posts) in
            
            let count = self.posts.count
            let adding = posts.count
            
            self.posts.append(contentsOf: posts)
            
            DispatchQueue.main.async {
                
                switch self.viewMode {
                case .list:
                    self.listCollectionView.performBatchUpdates({
                        
                        var indexPaths: [IndexPath] = []
                        for i in (count..<count+adding) {
                            indexPaths.append(IndexPath.init(row: i, section: 0))
                        }
                        
                        self.listCollectionView.insertItems(at: indexPaths)
                        
                    }) { (finished) in
                        self.listCollectionView.es.stopLoadingMore()
                        
                        self.isLoadingPosts = false
                        print("scroll loading false")
                    }
                case .square:
                    self.squareCollectionView.performBatchUpdates({
                        
                        var indexPaths: [IndexPath] = []
                        for i in (count..<count+adding) {
                            indexPaths.append(IndexPath.init(row: i, section: 0))
                        }
                        
                        self.squareCollectionView.insertItems(at: indexPaths)
                        
                    }) { (finished) in
                        self.squareCollectionView.es.stopLoadingMore()
                        
                        self.isLoadingPosts = false
                        print("scroll loading false")
                    }
                }
            }
        }
    }
    
    func didSelectFeedAction(_ feed: SSPost) {
        guard let partialRestaurant = feed.restaurant else {
            return
        }
        
        // load full restaurant data
        SVProgressHUD.show(withStatus: "Loading...")
        APIs.Restaurants.getRestaurant(of: partialRestaurant.restaurantID) { (restaurant) in
            // go to details
            let viewController = FeedDetailViewController.instance(feed: feed, restaurant: restaurant)
            self.navigationController?.pushViewController(viewController)
            
            SVProgressHUD.dismiss()
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
