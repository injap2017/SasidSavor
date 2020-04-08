//
//  FeedViewController.swift
//  Savor
//
//  Created by Edgar Sia on 10/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import MagazineLayout
import UIScrollView_InfiniteScroll
import FTPopOverMenu_Swift

enum FeedsViewMode: Int {
    case list
    case square
}

class FeedViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var squareCollectionView: UICollectionView!
    
    // MARK: - Properties
    var posts: [Feed] = FeedDataProvider.init().generateFakeFeeds()
    var viewMode: FeedsViewMode = .list {
        didSet {
            var frontView: UIView
            switch viewMode {
            case .list:
                frontView = listCollectionView
            default:
                frontView = squareCollectionView
            }
            self.view.bringSubviewToFront(frontView)
        }
    }
    
    static let postsPerLoad: Int = 3
}

// MARK: - Lifecycle
extension FeedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
//        self.loadPosts()
    }
}

// MARK: - Functions
extension FeedViewController {
    
    func initView() {
        
        // uicollectionview
        self.listCollectionView.collectionViewLayout = MagazineLayout.init()
        self.listCollectionView.register(FeedListItem.nib, forCellWithReuseIdentifier: FeedListItem.identifier)
        self.listCollectionView.addInfiniteScroll { (collectionView) in
            
        }
        
        let listRefreshControl = UIRefreshControl()
        listRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.listCollectionView.refreshControl = listRefreshControl
        
        self.squareCollectionView.collectionViewLayout = MagazineLayout.init()
        self.squareCollectionView.register(FeedSquareItem.nib, forCellWithReuseIdentifier: FeedSquareItem.identifier)
        self.squareCollectionView.addInfiniteScroll { (collectionView) in
            
        }
        
        let squareRefreshControl = UIRefreshControl()
        squareRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.squareCollectionView.refreshControl = squareRefreshControl
        
        // view mode popover
        self.configureFTPopOverMenu()
        
        // set view mode init list
        self.viewMode = .list
    }
    
    func configureFTPopOverMenu() {
        
    }
    
    func refreshView() {
        
    }
    
    @objc func refresh() {
//        posts.removeAll()
//        loadPosts()
    }
/*
    func loadPosts() {
        APIs.Posts.getRecentPosts(start: posts.first?.timestamp, limit: 10) { (posts) in
            self.posts = posts
        }
    }
*/
}

// MARK: - Actions
extension FeedViewController {
    
    @IBAction func viewMode(_ sender: UIBarButtonItem, event: UIEvent) {
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
}

// MARK: - UICollectionView
extension FeedViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case listCollectionView:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: FeedListItem.identifier, for: indexPath) as! FeedListItem
            let feed = self.posts[indexPath.row]
            item.feed = feed
            return item
        default:
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: FeedSquareItem.identifier, for: indexPath) as! FeedSquareItem
            let feed = self.posts[indexPath.row]
            item.feed = feed
            return item
        }
    }
}

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
