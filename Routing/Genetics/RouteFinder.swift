//
//  Routing.swift
//  Routing
//
//  Created by Matthew Calllahan on 8/9/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import Foundation

/// Implementation of the reproducing class Routes. Each Routes represents
/// two sets of paths taken by the two delivery drivers.
final class Routes: Reproducing {
    
    typealias Paths = (driver1: [Path], driver2: [Path])
    
    var paths: Paths
    
    let locations = [Location]()
    
    /// Fitness is measured as being above a certain threshold. Since we're
    /// trying to minimize distance traveled, fitness is negative.
    var fitness: Double {
        var distance1: Double = 0.0
        paths.driver1.forEach { distance1 -= $0.distance }
        
        var distance2: Double = 0.0
        paths.driver2.forEach { distance2 -= $0.distance }
        
        return distance1 + distance2
    }
    
    init(from member: Routes) {
        self.paths = member.paths
    }
    
    private init(with paths: Paths) {
        self.paths = paths
    }
    
    /// Mutation is implemented as follows:
    ///
    /// 1. Selected Routes are decomposed into two drivers
    /// 2. Each is iterated over 12 times (thus touching up to half of all locations)
    /// 3. During each iteration a given path is 'flipped' around such that the start
    ///    becomes the finish and vice versa
    /// 4. The result is returned as a new Routes object
    ///
    func mutate() {
        var first = paths.driver1
        var second = paths.driver2
        
        for _ in 1...12 {
            let index1 = Int(arc4random_uniform(UInt32(paths.driver1.count - 3))) + 2
            let index2 = Int(arc4random_uniform(UInt32(paths.driver1.count - 3))) + 2
            
            if index1 < first.count - 2 {
                first[index1] = Path(start: first[index1].destination, destination: first[index1].start)
                first[index1 - 1].destination = first[index1].start
                first[index1 + 1].start = first[index1].destination
            }
            
            if index2 < second.count - 2 {
                second[index2] = Path(start: second[index2].destination, destination: second[index2].start)
                second[index2 - 1].destination = second[index2].start
                second[index2 + 1].start = second[index2].destination
            }
        }
        
        paths = (first, second)
    }
    
    /// In our case a cross compares two Routes, maintains common locations
    /// between their paths 1 and 2 respectively, then randomly reassigns
    /// the remaining locations to those two paths.
    ///
    /// It would be worthwhile to explore more complex crosses that attempt
    /// to create children with higher odds of success than their parents.
    func cross(with other: Routes) -> (first: Routes, second: Routes) {
        let parent1 = Routes(from: self)
        let parent2 = Routes(from: other)
        
        let routes1 = childRoutes(of: parent1, and: parent2)
        let routes2 = childRoutes(of: parent1, and: parent2)
        
        return (first: Routes(with: routes1), second: Routes(with: routes2))
    }
    
    private func childRoutes(of parent1: Routes, and parent2: Routes) -> Paths {
        
        var childLocations1 = [Location]()
        var childLocations2 = [Location]()
        var remainder = [Location]()
        
        for location in AllLocations.locations {
            if location == AllLocations.home { continue }
            if parent1.paths.driver1.contains(where: { $0.destination == location }),
                parent2.paths.driver1.contains(where: { $0.destination == location }) {
                childLocations1.append(location)
            } else if parent1.paths.driver2.contains(where: { $0.destination == location }),
                parent2.paths.driver2.contains(where: { $0.destination == location }) {
                childLocations2.append(location)
            } else {
                remainder.append(location)
            }
        }
        
        remainder.forEach { location in
            arc4random_uniform(2) == 0 ? childLocations1.append(location) : childLocations2.append(location)
        }
        
        return (driver1: paths(from: childLocations1), driver2: paths(from: childLocations2))
    }
    
    /// Convenience method for getting array of paths from ordered array of locations.
    private func paths(from locations: [Location]) -> [Path] {
        var paths = [Path]()
        for i in 0...locations.count {
            switch i {
            case 0:
                paths.append(Path(start: AllLocations.home, destination: locations[i]))
            case 1..<locations.count:
                paths.append(Path(start: locations[i - 1], destination: locations[i]))
            case locations.count:
                paths.append(Path(start: locations[i - 1], destination: AllLocations.home))
            default:
                continue
            }
        }
        return paths
    }
    
    /// In our case there's a 50/50 chance that the 'random' individual will actually
    /// be 'planned', meaning that we create an individual by looking for the shortest
    /// paths from the home office. Otherwise the individual is truly random.
    static func randomInstance() -> Routes {
        guard arc4random_uniform(2) == 0 else { return plannedInstance() }
        let locations = AllLocations.locations.shuffled()
        let routes = constructRoutes(from: locations)
        return Routes(with: routes)
    }
    
    private static func plannedInstance() -> Routes {
        let locations = AllLocations.locations.sorted(by: {
            $0.coordinate.distance(from: AllLocations.home.coordinate) > $1.coordinate.distance(from: AllLocations.home.coordinate)
        })
        let routes = constructRoutes(from: locations)
        return Routes(with: routes)
    }
    
    private static func constructRoutes(from locations: [Location]) -> Paths {
        var paths1 = [Path]()
        var paths2 = [Path]()
        var currentLocation = AllLocations.home
        for i in stride(from: locations.count - 1, to: 0, by: -1) {
            let path = Path(start: currentLocation, destination: locations[i])
            arc4random_uniform(2) == 0 ? paths1.append(path) : paths2.append(path)
            currentLocation = (i == locations.count - 1) ? AllLocations.home : locations[i]
        }
        paths1.append(Path(start: paths1.last!.destination, destination: AllLocations.home))
        paths2.append(Path(start: paths2.last!.destination, destination: AllLocations.home))
        paths2.insert(Path(start: AllLocations.home, destination: paths2[0].start), at: 0)
        return (driver1: paths1, driver2: paths2)
    }
    
    func alertAboutIssue(with thing: Routes, string: String) {
        if thing.paths.driver1.count < 2 || thing.paths.driver2.count < 2 {
            print(string)
        }
    }
    
    /// Call to display final results in console and output a text file containing
    /// the two sets of paths. Note: URL to text file also appears in the console.
    public func outputResults() {
        let home = AllLocations.home
        var output = "*** Driver 1's Route ***\n"
        output += "Stop 1\n\(home.name)\n\(home.address)\n\(home.latitude)\n\(home.longitude)\n\n"
        for i in 0..<paths.driver1.count {
            let loc = paths.driver1[i].destination
            output += "Stop \(i+2)\n\(loc.name)\n\(loc.address)\n\(loc.latitude)\n\(loc.longitude)\n\n"
        }
        output += "*** Driver 2's Route ***\n"
        for i in 0..<paths.driver2.count {
            let loc = paths.driver2[i].destination
            output += "Stop \(i+2)\n\(loc.name)\n\(loc.address)\n\(loc.latitude)\n\(loc.longitude)\n\n"
        }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/output.txt")
        if FileManager.default.fileExists(atPath: path) { try? FileManager.default.removeItem(atPath: path) }
        let url = URL(fileURLWithPath: path)
        let data = output.data(using: .utf8)
        do {
            try data?.write(to: url)
            print("csv with output available here: \(path)")
        } catch {
            print("couldn't write full results")
        }
        
        var distance1: Double = 0.0
        paths.driver1.forEach { distance1 += $0.distance }
        
        var distance2: Double = 0.0
        paths.driver2.forEach { distance2 += $0.distance }
        
        var total = (distance1 + distance2) * 0.001
        total.round(.toNearestOrAwayFromZero)
        
        print("\n🌟 DRIVER 1 STOPS: \(paths.driver1.count - 1) *** DISTANCE TRAVELED: \(distance1 * 0.001) KM\n")
        print("\n🌟 DRIVER 2 STOPS: \(paths.driver2.count - 1) *** DISTANCE TRAVELED: \(distance2 * 0.001) KM\n")
        print("\nTOTAL DISTANCE TRAVELED: \(total) KM\n")
        
        print("--- THANK YOU! ---")
        print("\n")
    }
    
}
