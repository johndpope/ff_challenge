//
//  Path.swift
//  Routing
//
//  Created by Matthew Calllahan on 8/9/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import Foundation
import CoreLocation

/// Defines a path between two locations and their distance
struct Path {
    var start : Location
    var destination : Location
    var distance: Double {
        return start.coordinate.distance(from: destination.coordinate)
    }
}

extension Path: Equatable {
    /// Make paths equatable so they can be compared with each other
    static func == (lhs: Path, rhs: Path) -> Bool {
        return (lhs.start == rhs.start) && (lhs.destination == rhs.destination)
    }
}
