//
//  FeedDetailViewController.swift
//  Savor
//
//  Created by Edgar Sia on 4/16/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

enum FeedDetailViewSelector: Int {
    case info
    case posts
}

class FeedDetailViewController: UITableViewController {
    
    // MARK: - Properties
    var feed: SSPost?
    var restaurant: SSRestaurant?
    
    var feedDetailHeader: FeedDetailHeader?
    
    var viewSelector: FeedDetailViewSelector = .info {
        didSet {
            // refresh tableview to see the view parts
            self.tableView.reloadData()
        }
    }
}

// MARK: - Lifecycle
extension FeedDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension FeedDetailViewController {
    
    class func instance(feed: SSPost, restaurant: SSRestaurant) -> FeedDetailViewController {
        let storyboard = UIStoryboard.init(name: "Detail", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "feedDetail") as! FeedDetailViewController
        viewController.feed = feed
        viewController.restaurant = restaurant
        return viewController
    }
    
    func initView() {
        // title
        self.title = ""
        
        // cell
        self.tableView.register(ActionCell.nib, forCellReuseIdentifier: ActionCell.identifier)
        self.tableView.register(DetailCell.nib, forCellReuseIdentifier: DetailCell.identifier)
        self.tableView.register(FeedDetailCell.nib, forCellReuseIdentifier: FeedDetailCell.identifier)
        
        // header
        let width = UIScreen.main.bounds.size.width /* full screen width */
        let height = width + 32/* segmented control height */ + 16/* padding */
        let frame = CGRect.init(x: 0, y: 0, width: width, height: height)
        let feedDetailHeader = FeedDetailHeader.init(frame: frame)
        feedDetailHeader.feed = feed
        feedDetailHeader.segmentedControl.addTarget(self, action: #selector(viewSelectorValueChanged(_:)), for: .valueChanged)
        self.tableView.tableHeaderView = feedDetailHeader
        self.feedDetailHeader = feedDetailHeader
        
        // footer
        self.tableView.tableFooterView = UIView.init()
    }
}

// MARK: - TableView
extension FeedDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewSelector {
        case .info:
            // phone
            // address
            // home page
            // savored items
            // directions to here
            // find this menu item near me
            return 4
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewSelector {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
            cell.title = "Info" + "\(indexPath.row)"
            cell.isEnabled = true
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedDetailCell.identifier) as! FeedDetailCell
            cell.feed = feed
            return cell
        }
    }
}

// MARK: - Actions
extension FeedDetailViewController {
    @objc func viewSelectorValueChanged(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.viewSelector = .info
        } else {
            self.viewSelector = .posts
        }
    }
}
