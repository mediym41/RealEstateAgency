//
//  CheckButtons.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/17/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit

@IBDesignable
class CheckButtons: UIControl {
    var buttons: [UIButton] = []
    var selector: UIView!
    var selectedSegmentIndex = 0
    
    @IBInspectable
    var fontSize: CGFloat = 18 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var fontName: String = "Helvetica" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable
    var textColor: UIColor = .lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var canvasColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    var selectorColor: UIColor = .darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var selectorTextColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var margin: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var commaSeparatedButtonTitles: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let canvasPath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        canvasColor.setFill()
        canvasPath.fill()
        
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        let buttonTitles = commaSeparatedButtonTitles.components(separatedBy: ",")
        
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.font = UIFont(name: fontName, size: fontSize)
            
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            buttons.append(button)
        }
        
        buttons.first?.setTitleColor(selectorTextColor, for: .normal)
        
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        addSubview(sv)
        
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
    }
    
    @objc func buttonTapped(button: UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            
            if btn == button {
                selectedSegmentIndex = buttonIndex
                let selectorStartPosition = margin + frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3) {
                    self.selector.frame.origin.x = selectorStartPosition
                }
                
                btn.setTitleColor(selectorTextColor, for: .normal)
            }
        }
        
        sendActions(for: .valueChanged)
    }

}
