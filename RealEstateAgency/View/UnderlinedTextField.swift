//
//  UnderlinedTextField.swift
//  Kidcoin
//
//  Created by Mediym on 12/28/18.
//  Copyright © 2018 Mediym. All rights reserved.
//

import UIKit

@IBDesignable
class UnderlinedTextField: UITextField {
    
    @IBInspectable var lineThickness: CGFloat = 0.5 {
        didSet {
            if oldValue == lineThickness { return }
            if lineThickness == 0 {
                borderView.isHidden = true
            } else {
                borderView.frame.size = CGSize(width: borderView.frame.size.width, height: lineThickness)
            }
            
        }
    }
    @IBInspectable var lineColor: UIColor = .black {
        didSet {
            if oldValue == lineColor { return }
            borderView.backgroundColor = lineColor
        }
    }
    @IBInspectable var paddingHorizontal: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var paddingTop: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    @IBInspectable var kerningValue: CGFloat = 0 {
        didSet {
            kern(kerningValue: kerningValue)
        }
    }
    
    @IBInspectable var plcColor: UIColor? {
        didSet {
            if let color = plcColor {
                attributedPlaceholder = attributedPlaceholder?.updated(with: NSAttributedString.Key.foregroundColor, value: color)
                setNeedsDisplay()
            }
        }
    }
    @IBInspectable var errorFontSize: CGFloat = 12 {
        didSet {
            errorFont = UIFont(name: errorFontName, size: errorFontSize)
        }
    }
    @IBInspectable var errorFontName: String = "Helvetica" {
        didSet {
            errorFont = UIFont(name: errorFontName, size: errorFontSize)
        }
    }
    private var errorFont: UIFont? = .systemFont(ofSize: 50)
    
    
    @IBInspectable var errorColor: UIColor? 
    
    override var placeholder: String? {
        didSet {
            if let color = plcColor {
                attributedPlaceholder = attributedPlaceholder?.updated(with: NSAttributedString.Key.foregroundColor, value: color)
                setNeedsDisplay()
            }
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + paddingHorizontal / 2,
                      y: bounds.minY + paddingTop,
                      width: bounds.width - paddingHorizontal / 2,
                      height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.minX + paddingHorizontal / 2,
                      y: bounds.minY + paddingTop,
                      width: bounds.width - paddingHorizontal / 2,
                      height: bounds.height)
    }
    
    func hideStandardBorder() {
        self.borderStyle = .none
    }
    
    //MARK: Validation
    
    private lazy var errorLabel: UILabel = {
        let result = UILabel()
        result.font = errorFont
        result.textColor = .white
        result.text = ""
        result.isHidden = true
        self.addSubview(result)
        return result
    }()
    
    private lazy var borderView: UIView = {
        let result = UIView(frame: CGRect(x: 0, y: self.heightOriginalValue, width: 10, height: lineThickness))
        result.backgroundColor = self.lineColor
        self.addSubview(result)
        return result
    }()
    
    lazy var validator: Validator = EmptyStringValidator()
    
    private var initialized: Bool = false
    private var heightOriginalValue: CGFloat = 30.0
    private var originalTextColor: UIColor!
    private var originalLineColor: UIColor!
    private var originalPlcColor: UIColor!
    
    var hasError:Bool = false {
        didSet {
            updateUI()
        }
    }
    
    var errorMessage: String? {
        didSet {
            hasError = errorMessage != nil
            layoutSubviews()
        }
    }
    
    override func awakeFromNib() {
        contentVerticalAlignment = .center
        hideStandardBorder()
        clipsToBounds = false
        originalTextColor = textColor
        originalLineColor = lineColor
        originalPlcColor = plcColor
        updateUI()
        addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    @objc func textChanged() {
        guard textColor == errorColor else { return }
        textColor = originalTextColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heightOriginalValue = frame.height
        errorLabel.frame.origin = CGPoint(x: 0, y: heightOriginalValue)
        borderView.frame.origin = CGPoint(x: 0, y: frame.height - lineThickness)
        borderView.frame.size = CGSize(width: frame.width, height: lineThickness)
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : 0
        }
    }
    
    func validate() -> Bool {
        hasError = !validator.validate(value: text)
        return !hasError
    }
    
    func validateWithoutError() -> Bool {
        return validator.validate(value: text)
    }
    
    func updateUI() {
        if hasError {
            lineColor = errorColor ?? lineColor
            errorLabel.textColor = lineColor
            errorLabel.isHidden = false
            errorLabel.text = errorMessage ?? validator.error
            errorLabel.sizeToFit()
            
            plcColor = errorColor ?? plcColor
            textColor = errorColor ?? textColor
        } else {
            lineColor = originalLineColor
            plcColor = originalPlcColor
            textColor = originalTextColor
            errorLabel.isHidden = true
        }
    }
}
