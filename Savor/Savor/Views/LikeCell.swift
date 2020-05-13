//
//  LikeCell.swift
//  Savor
//
//  Created by Edgar Sia on 5/13/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class LikeCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "LikeCell"
    static let nib = UINib.init(nibName: "LikeCell", bundle: nil)
    
}
