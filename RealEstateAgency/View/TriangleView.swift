//
//  TriangleView.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/20/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TriangleView : UIView {
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let path = createRoundedTriangle(size: rect.size, radius: 10)
        context.addPath(path)
        
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
    }
    
    func createRoundedTriangle(size: CGSize, radius: CGFloat) -> CGPath {
        // Points of the triangle
        let point1 = CGPoint(x: -size.width / 2, y: size.height / 2)
        let point2 = CGPoint(x: 0, y: -size.height / 2)
        let point3 = CGPoint(x: size.width / 2, y: size.height / 2)
        
        let path = CGMutablePath()
        path.move(to: point1)
        path.addArc(tangent1End: point1, tangent2End: point2, radius: radius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: radius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: radius)
        path.closeSubpath()
        
        return path
    }

}
