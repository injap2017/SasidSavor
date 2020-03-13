//
//  PhotoItem.swift
//  Savor
//
//  Created by Edgar Sia on 3/12/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class PhotoItem: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Properties
    static let identifier = "PhotoItem"
    static let nib = UINib.init(nibName: "PhotoItem", bundle: nil)
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
}
