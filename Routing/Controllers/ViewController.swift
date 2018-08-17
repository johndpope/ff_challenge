//
//  ViewController.swift
//  Routing
//
//  Created by Matthew Calllahan on 8/8/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /// Pairs of routes less than 300,000 meters return immediately
    let threshold = -300000.0
    
    /// Begin button
    @IBAction func begin(_ sender: Any) {
        // Seed and run the process, which we output to the console and text file
        let routes = GeneticAlgorithm<Routes>(size: 30, threshold: threshold, maxGenerations: 1000)
        let result = routes.run()
        result.outputResults()
    }
    
}
