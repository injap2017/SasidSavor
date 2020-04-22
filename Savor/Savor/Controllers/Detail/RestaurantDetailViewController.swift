//
//  RestaurantDetailViewController.swift
//  Savor
//
//  Created by Edgar Sia on 4/16/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import MagazineLayout

enum RestaurantDetailViewSelector: Int {
    case info
    case items
}

class RestaurantDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var restaurant: SSRestaurant?
    
    var cells: [((UITableView) -> UITableViewCell, (UITableView) -> Void)] = [] /*(return cell, didSelectAction)*/
    
    var viewSelector: RestaurantDetailViewSelector = .info {
        didSet {
            // refresh tableview to see the view parts
            self.tableView.reloadData()
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
    
    class func instance(restaurant: SSRestaurant) -> RestaurantDetailViewController {
        let storyboard = UIStoryboard.init(name: "Detail", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "restaurantDetail") as! RestaurantDetailViewController
        viewController.restaurant = restaurant
        return viewController
    }
    
    func initView() {
        // title
        self.title = restaurant?.name
        
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
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewSelector {
        case .info:
            let cell = self.cells[indexPath.row].0(tableView)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantItemCell.identifier) as! RestaurantItemCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func directionsToHereCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
        cell.title = "Directions to Here"
        cell.isEnabled = true
        return cell
    }
}

// MARK: - Actions
extension RestaurantDetailViewController {
    @IBAction func viewSelectorValueChanged(_ segmentedControl: UISegmentedControl) {
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
}
