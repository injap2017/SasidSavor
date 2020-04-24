//
//  RestaurantDetailViewController.swift
//  Savor
//
//  Created by Edgar Sia on 4/16/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import SVProgressHUD

enum RestaurantDetailViewSelector: Int {
    case info
    case items
}

class RestaurantDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Properties
    var restaurant: SSRestaurant?
    var savoredFoods: [(SSFood, Double, [String], SSPost)]?
    
    var cells: [((UITableView) -> UITableViewCell, (UITableView) -> Void)] = [] /*(return cell, didSelectAction)*/
    
    var viewSelector: RestaurantDetailViewSelector = .info {
        didSet {
            // refresh tableview to see the view parts
            self.tableView?.reloadData()
        }
    }
}

// MARK: - Lifecycle
extension RestaurantDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension RestaurantDetailViewController {
    
    class func instance(restaurant: SSRestaurant, savoredFoods: [(SSFood, Double, [String], SSPost)]) -> RestaurantDetailViewController {
        let storyboard = UIStoryboard.init(name: "Detail", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "restaurantDetail") as! RestaurantDetailViewController
        viewController.restaurant = restaurant
        viewController.savoredFoods = savoredFoods
        return viewController
    }
    
    func initView() {
        // title
        self.title = restaurant?.name
        
        // uisegmentedcontrol
        self.segmentedControl.selectedSegmentIndex = viewSelector.rawValue
        self.segmentedControl.addTarget(self, action: #selector(viewSelectorValueChanged(_:)), for: .valueChanged)
        
        // cell
        self.tableView.register(ActionCell.nib, forCellReuseIdentifier: ActionCell.identifier)
        self.tableView.register(DetailCell.nib, forCellReuseIdentifier: DetailCell.identifier)
        self.tableView.register(RestaurantItemCell.nib, forCellReuseIdentifier: RestaurantItemCell.identifier)
        
        // footer
        self.tableView.tableFooterView = UIView.init()
        
        // cells
        if let displayPhone = self.restaurant?.displayPhone,
            !displayPhone.isWhitespace {
            self.cells.append((phoneCell, didSelectPhone))
        }
        if let location = self.restaurant?.location,
            location.displayAddress != nil {
            self.cells.append((addressCell, didSelectAddress))
        }
        if let url = self.restaurant?.url,
            !url.isWhitespace {
            self.cells.append((homePageCell, didSelectHomePage))
        }
        self.cells.append((directionsToHereCell, didSelectDirectionsToHere))
    }
}

// MARK: - UITableView
extension RestaurantDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewSelector {
        case .info:
            return self.cells.count
        default:
            return self.savoredFoods?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewSelector {
        case .info:
            let cell = self.cells[indexPath.row].0(tableView)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantItemCell.identifier) as! RestaurantItemCell
            cell.item = self.savoredFoods![indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewSelector {
        case .info:
            tableView.deselectRow(at: indexPath, animated: false)
            self.cells[indexPath.row].1(tableView)
        default:
            tableView.deselectRow(at: indexPath, animated: false)
            self.didSelectItem(savoredFoods![indexPath.row])
            break
        }
    }
    
    func phoneCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
        cell.title = "Phone"
        cell.detail = self.restaurant!.displayPhone
        return cell
    }
    
    func addressCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
        cell.title = "Address"
        cell.detail = self.restaurant!.displayAddress()
        return cell
    }
    
    func homePageCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.identifier) as! DetailCell
        cell.title = "Home Page"
        cell.detail = self.restaurant!.url
        return cell
    }
    
    func directionsToHereCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
        cell.title = "Directions to Here"
        cell.isEnabled = true
        return cell
    }
}

// MARK: - Actions
extension RestaurantDetailViewController {
    @objc func viewSelectorValueChanged(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            self.viewSelector = .info
        } else {
            self.viewSelector = .items
        }
    }
    
    func didSelectPhone(_ tableView: UITableView) {
        
    }
    
    func didSelectAddress(_ tableView: UITableView) {
        
    }
    
    func didSelectHomePage(_ tableView: UITableView) {
        
    }
    
    func didSelectDirectionsToHere(_ tableView: UITableView) {
        
    }
    
    func didSelectItem(_ item: (SSFood, Double, [String], SSPost)) {
        guard let restaurant = self.restaurant else {
            return
        }
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        // load all posts
        var posts: [SSPost] = []
        
        let dispatchGroup = DispatchGroup()
        
        let postIDs = item.2
        for postID in postIDs {
            dispatchGroup.enter()
            APIs.Posts.getPost(of: postID) { (post) in
                posts.append(post)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // sort posts by timestamp
            let sortedPosts = posts.sorted { (first, second) -> Bool in
                return first.timestamp > second.timestamp
            }
            
            // go to details
            let viewController = FeedDetailViewController.instance(food: item.0, totalRating: item.1, allFeeds: sortedPosts, restaurant: restaurant)
            viewController.viewSelector = .posts
            self.navigationController?.pushViewController(viewController)
            
            SVProgressHUD.dismiss()
        }
    }
}
