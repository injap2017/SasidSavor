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

enum FeedsViewMode: Int {
    case list
    case square
}

class FeedViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var squareCollectionView: UICollectionView!
    
    // MARK: - Properties
    let listRefreshControl = UIRefreshControl()
    let squareRefreshControl = UIRefreshControl()
    
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
    
    static let postsPerLoad: UInt = 10
}

// MARK: - Lifecycle
extension FeedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.initialLoadingAction()
    }
}

// MARK: - Functions
extension FeedViewController {
    
    func initView() {
        
        // uicollectionview
        self.listCollectionView.collectionViewLayout = MagazineLayout.init()
        self.listCollectionView.register(FeedListItem.nib, forCellWithReuseIdentifier: FeedListItem.identifier)
        self.listCollectionView.refreshControl = listRefreshControl
        listRefreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        
        self.squareCollectionView.collectionViewLayout = MagazineLayout.init()
        self.squareCollectionView.register(FeedSquareItem.nib, forCellWithReuseIdentifier: FeedSquareItem.identifier)
        self.squareCollectionView.refreshControl = squareRefreshControl
        squareRefreshControl.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        
        // view mode popover
        self.configureFTPopOverMenu()
        
        // set view mode init list
        self.viewMode = .square
    }
    
    func configureFTPopOverMenu() {
        
    }
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
    
    func initialLoadingAction() {
        SVProgressHUD.show(withStatus: "Loading...")
        APIs.Posts.getRecentPosts(start: nil, limit: FeedViewController.postsPerLoad) { (posts) in
            SVProgressHUD.dismiss()
            
            self.posts = posts
            
            DispatchQueue.main.async {
                
                switch self.viewMode {
                case .list:
                    self.listCollectionView.reloadData()
                case .square:
                    self.squareCollectionView.reloadData()
                }
            }
        }
    }
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        SVProgressHUD.show(withStatus: "Loading...")
        APIs.Posts.getRecentPosts(start: nil, limit: FeedViewController.postsPerLoad) { (posts) in
            SVProgressHUD.dismiss()

            self.posts = posts

            DispatchQueue.main.async {

                refreshControl.endRefreshing()

                switch self.viewMode {
                case .list:
                    self.listCollectionView.reloadData()
                case .square:
                    self.squareCollectionView.reloadData()
                }
            }
        }
    }
    
    @objc func infiniteScrollAction(_ collectionView: UICollectionView) {
        guard let lastPostTimestamp = self.posts.last?.timestamp else {
            return
        }
        
        APIs.Posts.getOldPosts(start: lastPostTimestamp, limit: FeedViewController.postsPerLoad) { (posts) in
            
            self.posts.append(contentsOf: posts)
            
            DispatchQueue.main.async {
                
                collectionView.reloadData()
            }
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
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.posts.count - 1 {
//            self.infiniteScrollAction(collectionView)
        }
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
