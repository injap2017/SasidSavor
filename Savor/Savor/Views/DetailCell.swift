//
//  DetailCell.swift
//  Savor
//
//  Created by Edgar Sia on 4/20/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    // MARK: - Properties
    static let identifier = "DetailCell"
    static let nib = UINib.init(nibName: "DetailCell", bundle: nil)
    
    var title: String = "" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    var detail: String = "" {
        didSet {
            self.detailLabel.text = detail
        }
    }
}
