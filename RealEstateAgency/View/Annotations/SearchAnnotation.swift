//
//  SearchAnnotation.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/20/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import Foundation
import MapKit

class SearchAnnotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D

    convenience override init() {
        self.init(title: nil, subtitle: nil, coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    }
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
