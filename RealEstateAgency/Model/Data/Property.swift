//
//  Property.swift
//  RealEstateAgency
//
//  Created by Mediym on 3/16/19.
//  Copyright © 2019 NSMedium. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import CoreLocation
import MapKit

enum BuyType: String {
    case rent, sale
    
    init(by value: Int) {
        switch value {
        case 0:
            self = .rent
        default:
            self = .sale
        }
    }
}

enum PropertyType: String {
    case flat, house
    
    init(by value: Int) {
        switch value {
        case 0:
            self = .house
        default:
            self = .flat
        }
    }
}

struct LocationPoint {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var json: [String: Any] {
        return [
            "latitude": latitude,
            "longitude": longitude
        ]
    }
    
    init?(dictionary: [String: Any]) {
        guard let latitude = dictionary["latitude"] as? Double,
            let longitude = dictionary["longitude"] as? Double
        else { return nil }
        
        self.latitude = latitude
        self.longitude = longitude
    }
}

class Property: NSObject {
    let id: String
    let type: PropertyType
    let buyType: BuyType
    let cost: Int
    
    let location: LocationPoint
    let region: String
    let street: String
    
    let square: Int
    let floor: Int
    let rooms: Int
    
    let sellerName: String
    let sellerEmail: String
    let date: Date
    
    init?(snapshot: QueryDocumentSnapshot) {
        self.id = snapshot.documentID
        let data = snapshot.data()
        
        if data["seller_name"] as! String == "1" {
            print("!")
        }
        guard let typeString = data["type"] as? String,
            let type = PropertyType(rawValue: typeString),
            let buyTypeString = data["buy_type"] as? String,
            let buyType = BuyType(rawValue: buyTypeString),
            let cost = data["cost"] as? Int,
            let locationData = data["location"] as? [String: Any],
            let location = LocationPoint(dictionary: locationData),
            let region = data["region"] as? String,
            let street = data["street"] as? String,
            let square = data["square"] as? Int,
            let floor = data["floor"] as? Int,
            let rooms = data["rooms"] as? Int,
            let sellerName = data["seller_name"] as? String,
            let sellerEmail = data["seller_email"] as? String,
            let timestamp = data["date"] as? Timestamp
        else {
            print("Failed")
            return nil
        }
        
        self.type = type
        self.buyType = buyType
        self.cost = cost
        self.location = location
        self.region = region
        self.street = street
        self.square = square
        self.floor = floor
        self.rooms = rooms
        self.sellerName = sellerName
        self.sellerEmail = sellerEmail
        self.date = timestamp.dateValue()
    }
}

extension Property: MKAnnotation {
    var title: String? {
        return "$ \(cost)"
    }
    
    var subtitle: String? {
        return "Square: \(square)"
    }
    
    var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }

}

class PropertyFilterItem {
    var types: [PropertyType]
    var buyTypes: [BuyType]
    
    var cost: ClosedRange<Int>
    var square: ClosedRange<Int>
    var floor: ClosedRange<Int>
    var rooms: ClosedRange<Int>
    
    init() {
        types = []
        buyTypes = []
        cost = 0...0
        square = 0...0
        floor = 0...0
        rooms = 0...0
    }
    
    func validate(item: Property) -> Bool {
        return types.contains(item.type) &&
            buyTypes.contains(item.buyType) &&
            cost.contains(item.cost) &&
            square.contains(item.square) &&
            (item.type == .house || floor.contains(item.floor)) &&
            rooms.contains(item.rooms)
    }
    
    var description: String {
        return """
        PropertyFilterItem
        Types: \(types.map { $0.rawValue }),
            Buy Types: \(buyTypes.map { $0.rawValue }),
            Cost: \(cost),
            Square: \(square),
            Floor: \(floor),
            Rooms: \(rooms)
        """
    }
}
