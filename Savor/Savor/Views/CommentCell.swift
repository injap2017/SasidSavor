//
//  CommentCell.swift
//  Savor
//
//  Created by Edgar Sia on 5/13/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "CommentCell"
    static let nib = UINib.init(nibName: "CommentCell", bundle: nil)
    
}
