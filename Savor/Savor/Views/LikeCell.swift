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
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "LikeCell"
    static let nib = UINib.init(nibName: "LikeCell", bundle: nil)
    
    var like: SSLike? {
        didSet {
            userPhotoImageView.image = UIImage.init(named: "account-gray")
            userNameLabel.text = nil
            userFullNameLabel.text = nil

            if let like = self.like {
                
                if let pictureURL = like.author?.profilePictureURL {
                    userPhotoImageView.sd_setImage(with: pictureURL)
                }
                
                userNameLabel.text = like.author?.fullname
                if let author = like.author {
                    userFullNameLabel.text = author.fullName()
                }
            }
        }
    }
}
