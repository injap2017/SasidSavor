//
//  InputFieldCell.swift
//  Savor
//
//  Created by Edgar Sia on 2/21/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class InputFieldCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    
    // MARK: - Properties
    static let identifier = "InputFieldCell"
    static let nib = UINib.init(nibName: "InputFieldCell", bundle: nil)
    
    var title: String = "" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    var isRequired: Bool = true {
        didSet {
            self.inputField.placeholder = isRequired ? "Required" : "Optional"
        }
    }
    
    var value: String {
        set {
            self.inputField.text = newValue
        }
        
        get {
            return self.inputField.text ?? ""
        }
    }
}

// MARK: - Functions
extension InputFieldCell {
    
    
}
