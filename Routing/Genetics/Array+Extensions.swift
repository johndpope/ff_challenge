//
//  Array+Extensions.swift
//  Routing
//
//  Created by Matthew Calllahan on 8/9/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import Foundation

extension Array {
    /// Implementation of shuffled for Swift versions < 4.2.
    public func shuffled() -> Array<Element> {
        var array = self
        for index in (1..<count).reversed() {
            let position = Int(arc4random_uniform(UInt32(index + 1)))
            array.swapAt(index, position)
        }
        return array
    }
}
