//
//  DCBaseButton.swift
//  DCKit
//
//  Created by Andrey Gordeev on 27/12/14.
//  Copyright (c) 2014 Andrey Gordeev (andrew8712@gmail.com). All rights reserved.
//

import UIKit

/// A base button class.
@IBDesignable open class DCBaseButton: UIButton {

    /// Text color for Normal state.
    @IBInspectable open var normalTextColor: UIColor = UIColor.lightGray {
        didSet {
            setTitleColor(normalTextColor, for: UIControl.State())
        }
    }

    /// Text color for Disabled state.
    @IBInspectable open var disabledTextColor: UIColor = UIColor.lightGray {
        didSet {
            setTitleColor(disabledTextColor, for: .disabled)
        }
    }

    /// Text color for Selected state.
    @IBInspectable open var selectedTextColor: UIColor = UIColor.lightGray {
        didSet {
            setTitleColor(selectedTextColor, for: .selected)
        }
    }

    /// Text color for Highlighted state.
    @IBInspectable open var highlightedTextColor: UIColor = UIColor.lightGray {
        didSet {
            setTitleColor(highlightedTextColor, for: .highlighted)
        }
    }

    /// Background color for Normal state.
    @IBInspectable open var normalBackgroundColor: UIColor = UIColor.white {
        didSet {
            updateColor()
        }
    }

    /// Background color for Disabled state.
    @IBInspectable open var disabledBackgroundColor: UIColor = UIColor.white {
        didSet {
            updateColor()
        }
    }

    /// Background color for Selected state.
    @IBInspectable open var selectedBackgroundColor: UIColor = UIColor(red: 37.0/255.0, green: 147.0/255.0, blue: 1.0/255.0, alpha: 1.0) {
        didSet {
            updateColor()
        }
    }

    /// Background color for Highlighted state.
    @IBInspectable open var highlightedBackgroundColor: UIColor? {
        didSet {
            updateColor()
        }
    }

    override open var isEnabled: Bool {
        didSet {
            updateColor()
        }
    }

    override open var isSelected: Bool {
        didSet {
            updateColor()
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            updateColor()
        }
    }

    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)

        customInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        customInit()
    }

    // MARK: - Build control

    /// Overriden method must call super.customInit().
    open func customInit() {
        configureFont()
        configureColor()
    }

    /// Configures control's font.
    open func configureFont() {
    }

    /// Configures control's color.
    open func configureColor() {
    }

    // MARK: - Misc

    /// Updates button's background color. Gets called after any of [state]BackgroundColor property was changed.
    open func updateColor() {
        if isHighlighted && highlightedBackgroundColor != nil {
            backgroundColor = highlightedBackgroundColor
        } else if !isEnabled {
            backgroundColor = disabledBackgroundColor
        } else {
            backgroundColor = isSelected ? selectedBackgroundColor : normalBackgroundColor
        }
    }

}
