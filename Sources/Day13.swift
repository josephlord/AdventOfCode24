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
    
    // With additions direction to result will be be very close to line y = x (45 degree line)
    // Need one vector above and the other below the line (unless both are parallel and exactly
    // right direction.
    
    let tGrad = Double(machine.prize.y) / Double(machine.prize.x)
    
    let aGrad = Double(machine.buttonAVector.y) / Double(machine.buttonAVector.x)
    let bGrad = Double(machine.buttonBVector.y) / Double(machine.buttonBVector.x)
    
    let steepest: Cord2D
    let shallowest: Cord2D
    let steepestGrad: Double
    let shallowestGrad: Double
    
    let bSteepest = bGrad > aGrad
    if bSteepest {
      steepest = machine.buttonBVector
      shallowest = machine.buttonAVector
      steepestGrad = bGrad
      shallowestGrad = aGrad
    } else {
      steepest = machine.buttonBVector
      shallowest = machine.buttonAVector
      steepestGrad = aGrad
      shallowestGrad = bGrad
    }
    
    if steepestGrad < tGrad || shallowestGrad > tGrad {
      // Catch the unhandled direct route with one vector case here so we can handle if needed.
      assert(abs(tGrad - steepestGrad) > 0.000_1)
      assert(abs(tGrad - shallowestGrad) > 0.000_1)
      return nil
    }
    
    let aproxRatio = approximateSolutionRatio(iterations: 6, vector1: steepest, vector2: shallowest, targetGrad: tGrad)
    
    let aproxVector = Cord2D(steepest.x * aproxRatio.0 + (shallowest.x * aproxRatio.1), steepest.y * aproxRatio.0 + (shallowest.y * aproxRatio.1))
    let approxIterations = min(machine.prize.x / aproxVector.x, machine.prize.y / aproxVector.y) - 50
    
    let result = solveFrom(
      steepest: steepest,
      shallowest: shallowest,
      target: machine.prize,
      steepestCount: approxIterations * aproxRatio.0,
      shallowestCount: approxIterations * aproxRatio.1)
    guard let result else { return nil }
    if bSteepest {
      return result.0 * 3 + result.1
    } else {
      return result.1 * 3 + result.0
    }
  }
  
  func solveFrom(steepest: Cord2D, shallowest: Cord2D, target: Cord2D, steepestCount: Int, shallowestCount: Int) -> (Int, Int)? {
    let tGrad = target.gradient
    var steepestCount = steepestCount
    var shallowestCount = shallowestCount
    var currentPos: Cord2D = .init(
      steepestCount * steepest.x + shallowestCount * shallowest.x,
      steepestCount * steepest.y + shallowestCount * shallowest.y)
    while currentPos.x < target.x && currentPos.y < target.y {
      if currentPos.gradient < tGrad {
        currentPos = currentPos + steepest
        steepestCount += 1
      } else {
        currentPos = currentPos + shallowest
        shallowestCount += 1
      }
    }
    if currentPos == target {
      return (steepestCount, shallowestCount)
    } else {
      return nil
    }
  }
  
  func approximateSolutionRatio(iterations: Int, vector1: Cord2D, vector2: Cord2D, targetGrad: Double) -> (Int, Int) {
    var vector1Count = 0
    var vector2Count = 0
    var currentPos: Cord2D = .init(0, 0)
    while vector1Count + vector2Count < iterations {
      let nextPlusVec1 = currentPos + vector1
      let nextPlusVec2 = currentPos + vector2
      if (nextPlusVec1.gradient == targetGrad) {
        return (vector1Count + 1, vector2Count)
      } else if (nextPlusVec2.gradient == targetGrad) {
        return (vector1Count, vector2Count + 1)
      } else if abs(targetGrad - nextPlusVec1.gradient) < abs(targetGrad - nextPlusVec2.gradient) {
        vector1Count += 1
        currentPos = nextPlusVec1
      } else {
        vector2Count += 1
        currentPos = nextPlusVec2
      }
    }
    
    return (vector1Count, vector2Count)
  }
  
  func part2() async throws -> Int {
    var machines = try Self.parseInput(data: data)
    for i in machines.indices {
      machines[i].prize.x += 10000000000000
      machines[i].prize.y += 10000000000000
    }
    let results = machines.map { self.minValEfficient(machine: $0) ?? 0 }
    
    return results.reduce(0,+)
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day13 {}

func *(lhs: Cord2D, rhs: Int) -> Cord2D {
  Cord2D(lhs.x * rhs, lhs.y * rhs)
}

extension Cord2D {
  var gradient: Double {
    Double(y) / Double(x)
  }
}
