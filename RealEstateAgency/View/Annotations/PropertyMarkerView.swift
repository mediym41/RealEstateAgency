//
//  AnnotationView.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/17/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import Foundation
import MapKit
import UIKit

private let multiWheelCycleClusterID = "multiWheelCycle"

protocol PropertyMarkerAnnotationViewDelegate: class {
    func showMoreButtonPressed(property: Property)
}

class PropertyMarkerAnnotationView: MKMarkerAnnotationView {
    
    static let identifier = "PropertyMarkerAnnotationView"
    weak var delegate: PropertyMarkerAnnotationViewDelegate?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "buildings"
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView != nil {
            self.superview?.bringSubviewToFront(self)
        }
        
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = self.bounds
        var isInside: Bool = rect.contains(point)
        if !isInside {
            for view in self.subviews {
                isInside = view.frame.contains(point)
                if isInside {
                    break
                }
            }
        }
        
        return isInside
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let property = annotation as? Property else { return }
        displayPriority = .defaultLow
        canShowCallout = false
        
        markerTintColor = getColor(by: property.buyType)
        glyphImage = getIcon(by: property.type)
        glyphTintColor = .white
    }

    // MARK: - Helpers
    func getColor(by type: BuyType) -> UIColor {
        switch type {
        case .rent:
            return #colorLiteral(red: 0.168627451, green: 0.2274509804, blue: 0.5137254902, alpha: 1)
        case .sale:
            return #colorLiteral(red: 0.9921568627, green: 0.6549019608, blue: 0.1058823529, alpha: 1)
        }
    }
    
    func getIcon(by type: PropertyType) -> UIImage {
        let image = type == .flat ? #imageLiteral(resourceName: "Flat") : #imageLiteral(resourceName: "House")
        return image.imageWithInsets(insetDimen: 5)
    }
}
