import Foundation
import RegexBuilder

struct Day13: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 0
  let puzzleName: String = "--- Day 13: Claw Contraption! ---"

  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  init(data: String) {
    self.data = data
  }

  struct ClawMachine {
    var prize: Cord2D
    var buttonAVector: Cord2D
    var buttonBVector: Cord2D
  }
  
  static func parseInput(data: String) throws -> [ClawMachine] {
    let clawMachineRegex = Regex {
      "Button A: X"
      Capture {
        Regex {
          One(CharacterClass.anyOf("+-"))
          OneOrMore(.digit)
        }
      } transform: { Int($0)! }
      ", Y"
      Capture {
        Regex {
          One(CharacterClass.anyOf("+-"))
          OneOrMore(.digit)
        }
      } transform: { Int($0)! }
      One(.newlineSequence)
      "Button B: X"
      Capture {
        Regex {
          One(CharacterClass.anyOf("+-"))
          OneOrMore(.digit)
        }
      }transform: { Int($0)! }
      ", Y"
      Capture {
        Regex {
          One(CharacterClass.anyOf("+-"))
          OneOrMore(.digit)
        }
      }transform: { Int($0)! }
      One(.newlineSequence)
      "Prize: X="
      Capture {
        OneOrMore(.digit)
      }transform: { Int($0)! }
      ", Y="
      Capture {
        OneOrMore(.digit)
      }transform: { Int($0)! }
    }
    
    let matches = data.matches(of: clawMachineRegex)
    return matches.map {
      .init(prize: Cord2D(($0.output.5), ($0.output.6)),
            buttonAVector: Cord2D($0.output.1, $0.output.2),
            buttonBVector: .init($0.output.3, $0.output.4)) }
  }
  
  func minVal100(machine: ClawMachine) -> Int? {
    var minScore: Int?
    let xALimit = machine.prize.x / machine.buttonAVector.x
    let yALimit = machine.prize.y / machine.buttonAVector.y
//    let xBLimit = machine.prize.x / machine.buttonBVector.x
//    let yBLimit = machine.prize.y / machine.buttonBVector.y
    let maxA = min(min(xALimit, yALimit), 100)
    
    for aCount in (0...maxA).reversed() {
      let target = machine.prize - machine.buttonAVector * aCount
      let bCount = target.x / machine.buttonBVector.x
      
      guard bCount <= 100,
            target.x % machine.buttonBVector.x == 0,
            target.y % machine.buttonBVector.y == 0,
            target.y / machine.buttonBVector.y == bCount
      else { continue }
      let score = bCount + 3 * aCount
      if let mScore = minScore {
        if score > mScore {
          return minScore // We have passed the optimum
        }
        minScore = score
      } else {
        minScore = score
      }
    }
    
    return minScore
  }
  
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    let machines = try Self.parseInput(data: data)
    let results = machines.map { self.minVal(machine: $0) ?? 0 }
    
    return results.reduce(0,+)
  }
  
  
  func minVal(machine: ClawMachine) -> Int? {
    var minScore: Int?
    let xBLimit = machine.prize.x / machine.buttonBVector.x
    let yBLimit = machine.prize.y / machine.buttonBVector.y
    //    let xBLimit = machine.prize.x / machine.buttonBVector.x
    //    let yBLimit = machine.prize.y / machine.buttonBVector.y
    let maxB = min(xBLimit, yBLimit)
    
    for bCount in (0...maxB).reversed() {
      let target = machine.prize - machine.buttonBVector * bCount
      let aCount = target.x / machine.buttonAVector.x
      let score = bCount + 3 * aCount
      if score > minScore ?? .max {
        return minScore // We have passed the optimum
      }
      guard target.x % machine.buttonAVector.x == 0,
            target.y % machine.buttonAVector.y == 0,
            target.y / machine.buttonAVector.y == aCount
      else { continue }
      minScore = score
    }
    return minScore
  }

  func minValEfficient(machine: ClawMachine) -> Int? {
    // 4 possible situations
    // 1) single solution (non parallel vectors)
    // 2) multiple solutions (A is multiple (possibly non-integer) of B or vice versa)
    // 3) A and B parallel and not aligned to prize - no solution
    // 4) A and B parallel and aligned but no integer solution
    // 5) A and B non-parallel but no integer solution
    
    // Approach solve vector equation with Doubles then verify with integers
    // Only in case 2 do we need to search for multiple options and they should
    // be identifiable if we know the ration
    
    let abXRatio = Double(machine.buttonAVector.x) / Double(machine.buttonBVector.x)
    let abYRatio = Double(machine.buttonAVector.y) / Double(machine.buttonBVector.y)
    
    let almostParallel = (0.9999..<1.0001).contains(abXRatio / abYRatio)
    
    if almostParallel {
      if Double(machine.prize.x) / 
      
      
      let aMoreEfficient = abXRatio > 3
      let bSearchSeq = 0...(machine.prize.x)
    } else {
      
    }
    
    
  }
  
  func part2() async throws -> Int {
    var machines = try Self.parseInput(data: data)
    for i in machines.indices {
      machines[i].prize.x += 10000000000000
      machines[i].prize.y += 10000000000000
    }
    let results = machines.map { self.minVal(machine: $0) ?? 0 }
    
    return results.reduce(0,+)
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day13 {}

func *(lhs: Cord2D, rhs: Int) -> Cord2D {
  Cord2D(lhs.x * rhs, lhs.y * rhs)
}
