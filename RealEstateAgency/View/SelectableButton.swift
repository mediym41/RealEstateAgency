//
//  SelectableButton.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/17/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit

class SelectableButton: UIButton {

    @IBInspectable var normalBackgroundColor: UIColor = .gray
    @IBInspectable var selectedBackgroundColor: UIColor = .black
    
    @IBInspectable var normalTextColor: UIColor = .black
    @IBInspectable var selectedTextColor: UIColor = .gray
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = normalBackgroundColor
        addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        self.setTitleColor(normalTextColor, for: .normal)
        self.setTitleColor(selectedTextColor, for: .selected)
        
        updateBackground(animated: false)
    }
    
    @objc func buttonPressed (_ sender: UIButton) {
        setSelect(!isSelected, animated: true)
    }
    
    func setSelect(_ newValue: Bool, animated: Bool) {
        guard isSelected != newValue else { return }
        isSelected = newValue
        updateBackground(animated: animated)
    }
    
    
    func updateBackground(animated: Bool) {
        let bgcColor = isSelected ? selectedBackgroundColor : normalBackgroundColor
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = bgcColor
        }
    }

}
