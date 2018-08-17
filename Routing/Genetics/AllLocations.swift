//
//  AllLocations.swift
//  Routing
//
//  Created by Matthew Calllahan on 8/10/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import Foundation

struct AllLocations {
    /// Get all locations except for home office.
    static var locations: [Location] {
        let path = Bundle.main.path(forResource: "Kiosk Coords", ofType: "txt")!
        let rows = try! String(contentsOfFile: path).components(separatedBy: "\r\n")
        var locations = [Location]()
        for index in stride(from: 0, to: 197, by: 4) {
            locations.append(Location(name: rows[index],
                                      address: rows[index + 1],
                                      latitude: Double(rows[index + 2])!,
                                      longitude: Double(rows[index + 3])!))
        }
        return locations
    }
    
    /// Get home office
    static var home: Location {
        return Location(name: "Farmers Fridge Corporate Office",
                        address: "Lake & Racine",
                        latitude: 41.8851024,
                        longitude: -87.6618988)
    }
    
}
