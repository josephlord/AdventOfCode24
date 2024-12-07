import Foundation
import RegexBuilder

extension Int {
  func raiseToPower(_ power: Int) -> Int {
    guard power != 0 else { return 1 }
    guard power > 0 else { preconditionFailure() }
    var result: Int = self
    for _ in 0..<power {
      result *= self
    }
    return result
  }
}

struct Day07: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 0
  let puzzleName: String = "--- Day 7: Bridge repair! ---"

  init(data: String) {
    self.data = data
  }

  static func parseInput(_ input: String) -> [(Int, [Int])] {
    let regex = Regex {
      TryCapture {
        Regex {
          OneOrMore {
            .digit
          }
        }
      } transform: { Int($0) }
      ": "
      Capture {
        OneOrMore {
          ChoiceOf {
            .digit
            " "
          }
        }
      }
    }
    let result: [(Int, [Int])] = input.lines.map { line in
      guard let match = try! regex.firstMatch(in: line)
      else { preconditionFailure() }
      let inputs = match.output.2.split(separator: " ").map { Int($0)! }
      return (match.output.1, inputs)
    }
    return result
  }
  
  func concat(lhs: Int, rhs: Int) -> Int {
    var result = lhs
    var shiftedR = rhs
    while shiftedR > 0 {
      shiftedR /= 10
      result *= 10
    }
    return result + rhs
  }
  
  func validateLineP2(target: Int, currentValue: Int, inputs: [Int].SubSequence) -> Bool {
    if currentValue > target {
      return false
    }
    if inputs.isEmpty {
      return currentValue == target
    }
    let tail = inputs.dropFirst()
    let head = inputs.first!
    if validateLineP2(target: target, currentValue: currentValue + head, inputs: tail) {
        return true
    }
    if validateLineP2(target: target, currentValue: currentValue * head, inputs: tail) {
        return true
    }
    if validateLineP2(target: target, currentValue: concat(lhs: currentValue, rhs: head), inputs: tail) {
        return true
    }
    return false
  }
  
  func validateLineP1(target: Int, inputs: [Int]) -> Bool {
    let permutations = 1 << inputs.count - 1
    for i in 0..<permutations {
      var computationValue = inputs.first ?? 0
      for j in inputs.indices.dropFirst() {
        if i & (1 << (j - 1)) != 0 {
          computationValue += inputs[j]
        } else {
          computationValue *= inputs[j]
        }
      }
      if computationValue == target {
        return true
      }
    }
    return false
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    var total = 0
    for (target, inputs) in Self.parseInput(data) {
      if validateLineP1(target: target, inputs: inputs) {
        total += target
      }
    }
    return total
  }
  
  func part2() async throws -> Int {
    var total = 0
    for (target, inputs) in Self.parseInput(data) {
      if validateLineP2(target: target, currentValue: inputs[0], inputs: inputs.dropFirst()) {
        total += target
      }
    }
    return total
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day07 {}
