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
    
    class func syncData(Restaurant restaurant: SSRestaurant, viewSelector: RestaurantDetailViewSelector, completion: @escaping (RestaurantDetailViewController) -> Void) {
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
                var savored: [(SSFood, Double, [String], SSPost)] = []
                for savoredFood in savoredFoods {
                    let food = foods[savoredFood.0]
                    var lastPost: SSPost?
                    if let lastPostID = savoredFood.2.first {
                        lastPost = lastPosts[lastPostID]
                    }
                    // needs one more time savored
                    if let food = food, let lastPost = lastPost {
                        savored.append((food, savoredFood.1, savoredFood.2, lastPost))
                    }
                }
                
                // go to details
                let viewController = RestaurantDetailViewController.instance(restaurant: restaurant, savoredFoods: savored)
                viewController.viewSelector = viewSelector
                
                completion(viewController)
            }
        }
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
            !displayPhone.isWhitespace,
            let phone = self.restaurant?.phone,
            !phone.isWhitespace{
            self.cells.append((phoneCell, didSelectPhone))
        }
        if let location = self.restaurant?.location,
            location.displayAddress != nil,
            self.restaurant?.coordinates != nil {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
        cell.title = "Home Page"
        cell.isEnabled = true
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
        let phoneNumber = self.restaurant!.phone
        SavorData.Accessories.call(phoneNumber: phoneNumber, on: self)
    }
    
    func didSelectAddress(_ tableView: UITableView) {
        let coordinate = self.restaurant!.coordinates
        let latitude = coordinate!.latitude
        let longitude = coordinate!.longitude
        let placeName = self.restaurant!.name
        SavorData.Accessories.openMapForPlace(latitude: latitude, longitude: longitude, placeName: placeName)
    }
    
    func didSelectHomePage(_ tableView: UITableView) {
        if let url = URL.init(string: self.restaurant!.url) {
            SavorData.Accessories.visit(url: url)
        }
    }
    
    func didSelectDirectionsToHere(_ tableView: UITableView) {
        let coordinate = self.restaurant!.coordinates
        let latitude = coordinate!.latitude
        let longitude = coordinate!.longitude
        SavorData.Accessories.navigate(latitude: latitude, longitude: longitude, on: self)
    }
    
    func didSelectItem(_ item: (SSFood, Double, [String], SSPost)) {
        guard let restaurant = self.restaurant else {
            return
        }
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        FeedDetailViewController.syncData(Restaurant: restaurant, Food: item.0, TotalRating: item.1, AllPosts: item.2, viewSelector: .posts) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
}
