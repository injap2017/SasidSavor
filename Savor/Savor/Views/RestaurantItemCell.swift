//
//  RestaurantItemCell.swift
//  Savor
//
//  Created by Edgar Sia on 4/22/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos


class RestaurantItemCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var itemPhotoImageView: UIImageView!
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    @IBOutlet weak var averageScore: CosmosView!
    @IBOutlet weak var postCountLabel: UILabel!
    
    @IBOutlet weak var lastPostDateLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "RestaurantItemCell"
    static let nib = UINib.init(nibName: "RestaurantItemCell", bundle: nil)
}
