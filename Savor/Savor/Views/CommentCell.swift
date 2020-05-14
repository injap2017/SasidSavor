//
//  CommentCell.swift
//  Savor
//
//  Created by Edgar Sia on 5/13/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

protocol CommentCellDelegate {
    func viewProfile(_ author: SSUser)
}

class CommentCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameButton: UIButton!
    
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var commentDateLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "CommentCell"
    static let nib = UINib.init(nibName: "CommentCell", bundle: nil)
    
    var delegate: CommentCellDelegate?
    
    var comment: SSComment? {
        didSet {
            userPhotoImageView.image = UIImage.init(named: "account-gray")
            userNameButton.setTitle(nil, for: .normal)
            
            commentTextLabel.text = nil
            commentDateLabel.text = nil
            
            if let comment = self.comment {
                
                if let pictureURL = comment.author?.profilePictureURL {
                    userPhotoImageView.sd_setImage(with: pictureURL)
                }
                
                userNameButton.setTitle(comment.author?.fullname, for: .normal)
                
                commentTextLabel.text = comment.text
                
                let timestampDate = Date(timeIntervalSince1970: comment.timestamp)
                commentDateLabel.text = SavorData.Accessories.timestampText(timestampDate)
            }
        }
    }
}
