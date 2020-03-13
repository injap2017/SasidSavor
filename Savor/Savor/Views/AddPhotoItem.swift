//
//  AddPhotoItem.swift
//  Savor
//
//  Created by Edgar Sia on 3/12/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class AddPhotoItem: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var cameraRollButton: UIButton!
    
    // MARK: - Properties
    static let identifier = "AddPhotoItem"
    static let nib = UINib.init(nibName: "AddPhotoItem", bundle: nil)

}
