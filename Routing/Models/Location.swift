//
//  Location.swift
//  Routing
//
//  Created by Matthew Calllahan on 8/8/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import Foundation
import CoreLocation

/// Defines a location pulled from the file "Kiosk Coords.txt"
struct Location: Equatable {
    
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    
    /// It's useful to have the location coordinate object
    var coordinate: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    /// Evaluate distance between this location and another
    func distance(from other: Location) -> Double {
        return self.coordinate.distance(from: other.coordinate)
    }
}
