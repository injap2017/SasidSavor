//
//  FeedViewController.swift
//  Savor
//
//  Created by Edgar Sia on 10/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import FTPopOverMenu_Swift

enum FeedsViewMode: Int {
    case list
    case gallery
}

class FeedViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var feeds: [Feed] = FeedDataProvider().generateFakeFeeds()
    var viewMode: FeedsViewMode = .list {
        didSet {
            var frontView: UIView
            switch self.viewMode {
            case .list:
                frontView = self.tableView
            default:
                frontView = self.collectionView
            }
            
            self.view.bringSubviewToFront(frontView)
        }
    }
}

// MARK: - Lifecycle
extension FeedViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension FeedViewController {
    
    func initView() {
        
        self.configureFTPopOverMenu()
        self.viewMode = .list
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
                self.viewMode = .gallery
            }
            
        }) {
            
        }
    }
}

// MARK: - UITableView
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedCell.identifier, for: indexPath) as! FeedCell
        
        let feed = self.feeds[indexPath.row]
        cell.feed = feed
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 143
    }
}

// MARK: - UICollectionView
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: FeedItem.identifier, for: indexPath) as! FeedItem
        
        let feed = self.feeds[indexPath.row]
        item.feed = feed
        
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let leftInset = layout.sectionInset.left
        let rightInset = layout.sectionInset.right
        let cellSpace = layout.minimumInteritemSpacing
        let collectionViewSize = collectionView.bounds.size
        
        let columnSize = CGFloat(3)
        
        let width = (collectionViewSize.width - leftInset - rightInset - (columnSize - 1) * cellSpace) / columnSize
        let height = width
        
        return CGSize.init(width: width, height: height)
    }
}
