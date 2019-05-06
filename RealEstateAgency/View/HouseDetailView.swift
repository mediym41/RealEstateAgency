//
//  HouseDetailView.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/20/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import UIKit
import MapKit

protocol HouseDetailViewDelegate: class {
    func showMoreButtonPressed(annotation: Property)
}

class HouseDetailView: UIView {

    @IBOutlet weak var houseImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var buyTypeLabel: UILabel!
    
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var squareLabel: UILabel!
    
    weak var delegate: HouseDetailViewDelegate?
    var annotation: Property?
    
    override var intrinsicContentSize: CGSize {
        get {
            return self.frame.size
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        houseImageView.kf.indicatorType = .activity
        addTriangle()
    }
    
    func addTriangle() {
        let triangle = CAShapeLayer()
        triangle.fillColor = backgroundColor?.cgColor ?? UIColor.white.cgColor
        triangle.path = createRoundedTriangle(width: 50, height: 20, radius: 3)
        triangle.position = CGPoint(x: bounds.maxX / 2 - 15, y: bounds.maxY - 3)
        triangle.shadowPath = nil
        
        layer.addSublayer(triangle)
    }
    
    func setup(annotation: Property) {
        self.annotation = annotation
        
        typeLabel.text = annotation.type.rawValue.capitalized
        buyTypeLabel.text = annotation.buyType.rawValue.capitalized
        streetLabel.text = annotation.street
        costLabel.text = "Cost: $ \(annotation.cost)"
        squareLabel.text = "Square: \(annotation.square) m"
    }
    
    func createRoundedTriangle(width: CGFloat, height: CGFloat, radius: CGFloat) -> CGPath {
        // Points of the triangle
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: width / 2, y: height)
        let point3 = CGPoint(x: width, y: 0)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: radius)
        path.closeSubpath()
        
        return path
    }
    
    @IBAction func showMoreButtonPressed() {
        guard let annotation = annotation else { return }
        delegate?.showMoreButtonPressed(annotation: annotation)
    }
    
}
