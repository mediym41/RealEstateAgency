//
//  Extension.swift
//  MediumChat.ios
//
//  Created by Mediym on 3/7/19.
//  Copyright © 2019 Mediym. All rights reserved.
//

import UIKit
import MapKit

extension UIViewController {
    static var name: String {
        return String(describing: self)
    }
    
    class func instantiate() -> Self {
        return AppStoryboard.main.viewController(viewControllerClass: self)
    }
    
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle: nil)
    }
    
    func performSegueToReturnBack() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension UIStoryboard {
    public static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: .main)
    }
}

extension UIView {
    static var name: String {
        return String(describing: self)
    }
    
    class func loadFromNib<T: UIView>() -> T {
        let nib  = UINib.init(nibName: name, bundle: nil)
        let nibObjects = nib.instantiate(withOwner: nil, options: nil)
        for object in nibObjects {
            if let result = object as? T {
                return result
            }
        }
        
        fatalError("Invalid xib name of view")
    }
    
    var rootView: UIView? {
        var parentView = superview
        while let superview = parentView?.superview {
            parentView = superview
        }
        
        return parentView
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func getConstraint(type: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint? {
        for constraint in self.constraints {
            if constraint.firstAttribute == type && constraint.relation == relation {
                return constraint
            }
        }
        return nil
    }
        
}

extension MKMapView {
    var annotationsNoUserLocation : [MKAnnotation] {
        get {
            return self.annotations.filter{ !($0 is MKUserLocation) }
        }
    }
    
    func removeAllAnnotations(withUserLocation: Bool = true) {
        let annotationsForRemove = withUserLocation ? annotations : annotationsNoUserLocation
        removeAnnotations(annotationsForRemove)
    }
}

// MARK: - UIFont
extension UIFont {
    static func museoSans(style: Int, size: CGFloat) -> UIFont {
        return UIFont(name: "MuseoSans-\(style)", size: size)!
    }
    
    static func museoCyrl(style: Int, size: CGFloat) -> UIFont {
        return UIFont(name: "MuseoCyrl-\(style)", size: size)!
    }
}

// MARK: - UITextField
extension UITextField {
    func kern(kerningValue: CGFloat) {
        self.attributedText =  NSAttributedString(string: self.text ?? "", attributes: [
            NSAttributedString.Key.kern: kerningValue,
            NSAttributedString.Key.font: font as Any,
            NSAttributedString.Key.foregroundColor: self.textColor as Any
            ])
    }
}

// MARK: - CGRect
extension CGRect {
    var centerY: CGFloat {
        return minY + height / CGFloat(2)
    }
    
    var centerX: CGFloat {
        return minX + width / CGFloat(2)
    }
}

// MARK: - UILabel
extension UILabel {
    
    func kern(kerningValue: CGFloat) {
        self.attributedText =  NSAttributedString(string: self.text ?? "", attributes: [
            NSAttributedString.Key.kern: kerningValue,
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: self.textColor
            ])
    }
    
    func getAttributes() -> [NSAttributedString.Key : Any] {
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor
        ]
    }
    
    func setTextWhileKeepingAttributes(_ string: String) {
        if let newAttributedText = self.attributedText {
            let mutableAttributedText = newAttributedText.mutableCopy() as! NSMutableAttributedString
            
            mutableAttributedText.mutableString.setString(string)
            self.attributedText = mutableAttributedText
        } else {
            self.text = string
        }
    }
}


// MARK: - UITableView
extension UITableView {
    func register(type: UITableViewCell.Type) {
        let typeName = type.name
        let nib = UINib(nibName: typeName, bundle: nil)
        self.register(nib, forCellReuseIdentifier: typeName)
    }
    
    func register(type: UITableViewHeaderFooterView.Type) {
        let typeName = type.name
        let nib = UINib(nibName: typeName, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: typeName)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: type.name, for: indexPath) as! T
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(with type: T.Type) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: type.name) as! T
    }
    
    func scrollToBottom(animated: Bool) {
        let lastSection = numberOfSections-1
        let lastRow = numberOfRows(inSection: lastSection)-1
        guard lastSection >= 0, lastRow >= 0 else { return }
        let lastIndexPath = IndexPath(row: lastRow, section: lastSection)
        scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
    }
}

// MARK: - UIImage
extension UIImage {
    func imageWithInsets(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
    }
    
    func imageWithInset(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(self.renderingMode)
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
    
}
