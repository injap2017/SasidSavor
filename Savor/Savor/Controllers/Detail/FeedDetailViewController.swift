//
//  FeedDetailViewController.swift
//  Savor
//
//  Created by Edgar Sia on 4/16/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import SVProgressHUD

enum FeedDetailViewSelector: Int {
    case info
    case posts
}

class FeedDetailViewController: UITableViewController {
    
    // MARK: - Properties
    var food: SSFood?
    var totalRating: Double?
    var allFeeds: [SSPost]?
    var restaurant: SSRestaurant?
    
    var feedDetailHeader: FeedDetailHeader?
    var cells: [((UITableView) -> UITableViewCell, (UITableView) -> Void)] = [] /*(return cell, didSelectAction)*/
    
    var viewSelector: FeedDetailViewSelector = .info {
        didSet {
            // refresh tableview to see the view parts
            self.tableView?.reloadData()
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
    
    class func instance(food: SSFood, totalRating: Double, allFeeds: [SSPost], restaurant: SSRestaurant) -> FeedDetailViewController {
        let storyboard = UIStoryboard.init(name: "Detail", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "feedDetail") as! FeedDetailViewController
        viewController.food = food
        viewController.totalRating = totalRating
        viewController.allFeeds = allFeeds
        viewController.restaurant = restaurant
        return viewController
    }
    
    func initView() {
        // title
        self.title = food?.name
        
        // cell
        self.tableView.register(ActionCell.nib, forCellReuseIdentifier: ActionCell.identifier)
        self.tableView.register(DetailCell.nib, forCellReuseIdentifier: DetailCell.identifier)
        self.tableView.register(FeedDetailCell.nib, forCellReuseIdentifier: FeedDetailCell.identifier)
        
        // header
        let width = UIScreen.main.bounds.size.width /* full screen width */
        let height = width + 32/* segmented control height */ + 16/* padding */
        let frame = CGRect.init(x: 0, y: 0, width: width, height: height)
        let feedDetailHeader = FeedDetailHeader.init(frame: frame)
        feedDetailHeader.data = (food!, totalRating!, allFeeds!, restaurant!)
        feedDetailHeader.segmentedControl.selectedSegmentIndex = viewSelector.rawValue
        feedDetailHeader.segmentedControl.addTarget(self, action: #selector(viewSelectorValueChanged(_:)), for: .valueChanged)
        feedDetailHeader.imageSlideShow.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(didTapImageSlideshow)))
        self.tableView.tableHeaderView = feedDetailHeader
        self.feedDetailHeader = feedDetailHeader
        
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
        self.cells.append((savoredItemsCell, didSelectSavoredItems))
        self.cells.append((directionsToHereCell, didSelectDirectionsToHere))
        self.cells.append((findThisMenuItemNearMeCell, didSelectFindThisMenuItemNearMe))
    }
}

// MARK: - TableView
extension FeedDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewSelector {
        case .info:
            return self.cells.count
        default:
            return self.allFeeds?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewSelector {
        case .info:
            let cell = self.cells[indexPath.row].0(tableView)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: FeedDetailCell.identifier) as! FeedDetailCell
            cell.feed = allFeeds![indexPath.row]
            cell.selectionStyle = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewSelector {
        case .info:
            tableView.deselectRow(at: indexPath, animated: false)
            self.cells[indexPath.row].1(tableView)
        default:
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
    
    func savoredItemsCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
        cell.title = "Savored Items"
        cell.isEnabled = true
        return cell
    }
    
    func directionsToHereCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
        cell.title = "Directions to Here"
        cell.isEnabled = true
        return cell
    }
    
    func findThisMenuItemNearMeCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
        cell.title = "Find This Menu Item Near Me"
        cell.isEnabled = true
        return cell
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
    
    @objc func didTapImageSlideshow() {
        // full screen slide show
        self.feedDetailHeader?.imageSlideShow.presentFullScreenController(from: self)
    }
    
    func didSelectPhone(_ tableView: UITableView) {
        
    }
    
    func didSelectAddress(_ tableView: UITableView) {
        
    }
    
    func didSelectHomePage(_ tableView: UITableView) {
        
    }
    
    func didSelectSavoredItems(_ tableView: UITableView) {
        guard let restaurant = self.restaurant else {
            return
        }
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        // load all savored foods
        APIs.Savored.getSavoredFoods(in: restaurant.restaurantID) { (savoredFoods) in
            // load food, the total rating and the last post
            var foods: [String: SSFood] = [:]
            var lastPosts: [String: SSPost] = [:]
            
            let dispatchGroup = DispatchGroup()
            
            for savoredFood in savoredFoods {
                let foodID = savoredFood.0
                dispatchGroup.enter()
                APIs.Foods.getFood(of: foodID) { (food) in
                    foods[foodID] = food
                    dispatchGroup.leave()
                }
                if let lastPostID = savoredFood.2.first {
                    dispatchGroup.enter()
                    APIs.Posts.getPost(of: lastPostID) { (post) in
                        lastPosts[lastPostID] = post
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                var savored: [(SSFood, Double, Int, SSPost)] = []
                for savoredFood in savoredFoods {
                    let food = foods[savoredFood.0]
                    var lastPost: SSPost?
                    if let lastPostID = savoredFood.2.first {
                        lastPost = lastPosts[lastPostID]
                    }
                    // needs one more time savored
                    if let food = food, let lastPost = lastPost {
                        savored.append((food, savoredFood.1, savoredFood.2.count, lastPost))
                    }
                }
                
                // go to details
                let viewController = RestaurantDetailViewController.instance(restaurant: restaurant, savoredFoods: savored)
                viewController.viewSelector = .items
                self.navigationController?.pushViewController(viewController)
                
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func didSelectDirectionsToHere(_ tableView: UITableView) {
        
    }
    
    func didSelectFindThisMenuItemNearMe(_ tableView: UITableView) {
        
    }
}
