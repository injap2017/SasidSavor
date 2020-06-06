//
//  FeedViewModePopUp.swift
//  Savor
//
//  Created by Edgar Sia on 6/5/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import KUIPopOver

protocol FeedViewModePopUpDelegate {
    func didSelectViewMode(_ viewMode: FeedViewMode)
}

class FeedViewModePopUp: UITableViewController, KUIPopOverUsable {
    
    // MARK: - KUIPopOverUsable
    var contentSize: CGSize {
        return CGSize(width: 200.0, height: 88.0)
    }
    
    // MARK: - Properties
    var listCell: UITableViewCell?
    var galleryCell: UITableViewCell?
    
    var _viewMode: FeedViewMode = .list
    var viewMode: FeedViewMode {
        get {
            return _viewMode
        }
        set {
            if _viewMode == newValue {
                return
            }
            
            switch _viewMode {
            case .list:
                listCell?.accessoryType = .none
            default:
                galleryCell?.accessoryType = .none
            }
            
            switch newValue {
            case .list:
                listCell?.accessoryType = .checkmark
            default:
                galleryCell?.accessoryType = .checkmark
            }
            
            _viewMode = newValue
        }
    }
    
    var delegate: FeedViewModePopUpDelegate?
}

// MARK: - Lifecycle
extension FeedViewModePopUp {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension FeedViewModePopUp {
    
    func initView() {
        // disable scrolling
        self.tableView.alwaysBounceVertical = false
    }
}

// MARK: - TableView
extension FeedViewModePopUp {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = UITableViewCell.init()
            cell.textLabel?.text = "List"
            cell.imageView?.image = UIImage.init(named: "format-list-bulleted-square")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor.black
            cell.accessoryType = self.viewMode == .list ? .checkmark : .none
            self.listCell = cell
            return cell
        default:
            let cell = UITableViewCell.init()
            cell.textLabel?.text = "Gallery"
            cell.imageView?.image = UIImage.init(named: "view-grid")?.withRenderingMode(.alwaysTemplate)
            cell.imageView?.tintColor = UIColor.black
            cell.accessoryType = self.viewMode == .square ? .checkmark : .none
            self.galleryCell = cell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.row {
        case 0:
            self.viewMode = .list
        default:
            self.viewMode = .square
        }
        
        self.delegate?.didSelectViewMode(viewMode)
        
        self.dismissPopover(animated: true)
    }
}
