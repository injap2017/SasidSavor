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
        
        self.tableView.register(InputFieldCell.nib, forCellReuseIdentifier: InputFieldCell.identifier)
        self.tableView.register(ActionCell.nib, forCellReuseIdentifier: ActionCell.identifier)
    }
}

// MARK: - Functions
extension FeedDetailViewController {
    
    class func instance() -> FeedDetailViewController {
        let storyboard = UIStoryboard.init(name: "Detail", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "feedDetail") as! FeedDetailViewController
        return viewController
    }
}

// MARK: - TableView
extension FeedDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewSelector {
        case .info:
            // calculate the count of items non empty
            return 4
        default:
            return 2
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
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
            cell.title = "Posts" + "\(indexPath.row)"
            cell.isEnabled = true
            return cell
        }
    }
}

// MARK: - Actions
extension FeedDetailViewController {
    @IBAction func viewSelectorValueChanged(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.viewSelector = .info
        } else {
            self.viewSelector = .posts
        }
    }
}
