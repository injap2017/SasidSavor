//
//  CommentsPostDetailCell.swift
//  Savor
//
//  Created by Edgar Sia on 5/13/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos

class CommentsPostDetailCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postPhotoImageView: UIImageView!
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDescriptionLabel: UILabel!
    @IBOutlet weak var restaurantNameAddressLabel: UILabel!
    
    @IBOutlet weak var postScore: CosmosView!
    
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var commentsImageView: UIImageView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "CommentsPostDetailCell"
    static let nib = UINib.init(nibName: "CommentsPostDetailCell", bundle: nil)
}
