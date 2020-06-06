//
//  FeedFilterModePopUp.swift
//  Savor
//
//  Created by Edgar Sia on 6/5/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import KUIPopOver

protocol FeedFilterModePopUpDelegate {
    func didSelectSource(_ source: FeedSource)
}

class FeedFilterModePopUp: UITableViewController, KUIPopOverUsable {
    
    // MARK: - KUIPopOverUsable
    var contentSize: CGSize {
        return CGSize(width: 200.0, height: 88.0)
    }
    
    // MARK: - Properties
    var allPostsCell: UITableViewCell?
    var friendsCell: UITableViewCell?
    
    var _source: FeedSource = .allPosts
    var source: FeedSource {
        get {
            return _source
        }
        set {
            if _source == newValue {
                return
            }
            
            switch _source {
            case .allPosts:
                allPostsCell?.accessoryType = .none
            default:
                friendsCell?.accessoryType = .none
            }
            
            switch newValue {
            case .allPosts:
                allPostsCell?.accessoryType = .checkmark
            default:
                friendsCell?.accessoryType = .checkmark
            }
            
            _source = newValue
        }
    }
    
    var delegate: FeedFilterModePopUpDelegate?
}

// MARK: - Lifecycle
extension FeedFilterModePopUp {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension FeedFilterModePopUp {
    
    func initView() {
        // disable scrolling
        self.tableView.alwaysBounceVertical = false
    }
}

// MARK: - TableView
extension FeedFilterModePopUp {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = UITableViewCell.init()
            cell.textLabel?.text = "All Posts"
            cell.imageView?.image = UIImage.init(named: "web")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor.black
            cell.accessoryType = self.source == .allPosts ? .checkmark : .none
            self.allPostsCell = cell
            return cell
        default:
            let cell = UITableViewCell.init()
            cell.textLabel?.text = "Friends"
            cell.imageView?.image = UIImage.init(named: "account-group")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor.black
            cell.accessoryType = self.source == .friends ? .checkmark : .none
            self.friendsCell = cell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.row {
        case 0:
            self.source = .allPosts
        default:
            self.source = .friends
        }
        
        self.delegate?.didSelectSource(source)
        
        self.dismissPopover(animated: true)
    }
}
