//
//  Genetics.swift
//  Routing
//
//  Created by Matthew Calllahan on 8/9/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import Foundation

/// Classes that conform to the Reproducing protocol can 'reproduce' populations of themselves
/// to produce new generations.
protocol Reproducing {
    
    // Measures the fitness of an individual
    var fitness: Double { get }
    
    // Creates a copy from another individual
    init(from member: Self)
    
    // Make minor mutations
    func mutate()
    
    // Cross with another individual
    func cross(with other: Self) -> (first: Self, second: Self)
    
    // Create a new random individual
    static func randomInstance() -> Self
    
    // Output info about the individual
    func outputResults()
    
    // Useful in debugging
    func alertAboutIssue(with thing: Self, string: String)
    
}

extension Reproducing {
    
    /// Protocol extension available to all conforming types that produces
    /// a random number (not available in Swift versions less than 4.2)
    func random() -> Double {
        srand48(Int(Date().timeIntervalSince1970))
        return drand48()
    }
    
}

/// Methods to manage populations and generations. Accepts a type
/// that conforms to Reproducing.
class GeneticAlgorithm<T: Reproducing> {
    
    let threshold: Double
    let maxGenerations: Int
    let mutationChance: Double
    let crossoverChance: Double
    
    var population: [T]
    var fitnessCache: [Double]
    var fitnessSum: Double = -Double.greatestFiniteMagnitude
    var participants = 4
    
    /// Create a new algorithm with default values specified
    init(size: Int,
         threshold: Double,
         maxGenerations: Int,
         mutationChance: Double = 0.3,
         crossoverChance: Double = 0.3) {
    
        self.threshold = threshold
        self.maxGenerations = maxGenerations
        self.mutationChance = mutationChance
        self.crossoverChance = crossoverChance
        
        population = [T]()
        
        for _ in 0..<size {
            population.append(T.randomInstance())
        }
        
        fitnessCache = [Double](repeating: -Double.greatestFiniteMagnitude, count: size)
    }
    
    /// Implementing random for this class
    private func random() -> Double {
        srand48(Int(Date().timeIntervalSince1970))
        return drand48()
    }
    
    /// Have individuals duke it out
    private func pickTournament(participants: Int) -> T {
        var best = T.randomInstance()
        var bestFitness = best.fitness
        for _ in 0..<participants {
            let test = Int(arc4random_uniform(UInt32(population.count)))
            if fitnessCache[test] > bestFitness {
                bestFitness = fitnessCache[test]
                best = population[test]
            }
        }
        return best
    }
    
    /// Compare members of the population for fitness and use them
    /// to seed a new generation
    private func reproduce() {
        var newGeneration = [T]()
        while newGeneration.count < population.count {
            let parents = (first: pickTournament(participants: participants), second: pickTournament(participants: participants))
            if random() < crossoverChance {
                let children = parents.first.cross(with: parents.second)
                newGeneration.append(children.first)
                newGeneration.append(children.second)
            } else {
                newGeneration.append(parents.first)
                newGeneration.append(parents.second)
            }
        }
        if newGeneration.count > population.count { newGeneration.removeLast() }
        population = newGeneration.compactMap { $0 }
    }
    
    /// Place this where necessary for debugging
    private func alertAboutProblem(thing: T? = nil, string: String) {
        if thing == nil, let pop1 = population.first {
            pop1.alertAboutIssue(with: pop1, string: string)
        } else if let thing = thing {
            thing.alertAboutIssue(with: thing, string: string)
        }
    }
    
    /// Mutate members of the population on each run
    private func checkForMutation() {
        population.forEach { if random() < mutationChance { $0.mutate() } }
    }
    
    /// This is the only public class. Use this to run after initializing a new
    /// version of the algorithm.
    public func run() -> T {
        var best = T.randomInstance()
        var bestFit = best.fitness
        for index in 1...maxGenerations {
            print("\ngeneration \(index)")
            print("best fit \(-bestFit * 0.001)KM total")
            print("average \(fitnessSum / Double(fitnessCache.count) * 0.001)")
            for (i, j) in population.enumerated() {
                fitnessCache[i] = j.fitness
                if fitnessCache[i] >= threshold {
                    return j
                }
                if fitnessCache[i] > bestFit {
                    best = T(from: j)
                    bestFit = fitnessCache[i]
                }
            }
            fitnessSum = fitnessCache.reduce(0, +)
            reproduce()
            checkForMutation()
        }
        return best
    }
}
