//
//  ActionCell.swift
//  Savor
//
//  Created by Edgar Sia on 2/21/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class ActionCell: UITableViewCell {

    // MARK: - Properties
    static let identifier = "ActionCell"
    static let nib = UINib.init(nibName: "ActionCell", bundle: nil)
    
    var isEnabled: Bool = true {
        didSet {
            self.selectionStyle = isEnabled ? .default : .none
            self.textLabel?.textColor = isEnabled ? .systemBlue : .systemGray
        }
    }
    
    var title: String = "" {
        didSet {
            self.textLabel?.text = title
        }
    }
}

// MARK: - Functions
extension ActionCell {
    
}
