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
  func part1a() async throws -> Int {
    var total = 0
    for (target, inputs) in Self.parseInput(data) {
      if validateLineP1(target: target, inputs: inputs) {
        total += target
      }
    }
    return total
  }
  
  func part1() async throws -> Int {
    try await part1b()
  }
  
  func validateLineP1a(target: Int, currentValue: Int, inputs: [Int].SubSequence) -> Bool {
    if currentValue > target {
      return false
    }
    if inputs.isEmpty {
      return currentValue == target
    }
    let tail = inputs.dropFirst()
    let head = inputs.first!
    if validateLineP1a(target: target, currentValue: currentValue + head, inputs: tail) {
        return true
    }
    if validateLineP1a(target: target, currentValue: currentValue * head, inputs: tail) {
        return true
    }
    return false
  }
  
  func part1b() async throws -> Int {
    var total = 0
    for (target, inputs) in Self.parseInput(data) {
      if validateLineP1a(target: target, currentValue: inputs.first!, inputs: inputs.dropFirst()) {
        total += target
      }
    }
    return total
  }
  
  func part2a() async throws -> Int {
    var total = 0
    for (target, inputs) in Self.parseInput(data) {
      if validateLineP2(target: target, currentValue: inputs[0], inputs: inputs.dropFirst()) {
        total += target
      }
    }
    return total
  }
  
  func validateLineP2(target: Int, inputs: [Int]) -> Bool {
    for i in 0..<Int.maxTernery(forTits: inputs.count) {
      var computationValue = inputs.first ?? 0
      for j in inputs.indices.dropFirst() {
        switch i.tit(j) {
        case 0:
          computationValue = concat(lhs: computationValue, rhs: inputs[j])
        case 1:
          computationValue *= inputs[j]
        case 2:
          computationValue += inputs[j]
        default:
          preconditionFailure()
        }
      }
      if computationValue == target {
        return true
      }
    }
    return false
  }
  
  func validateLineP2c(target: Int, inputs: [Int].SubSequence) -> Bool {
    for i in TernaryIterator(digits: inputs.count - 1) {
      var computationValue = inputs.first ?? 0
      for j in inputs.indices.dropFirst() {
        switch (i >> ((j - 1) << 1)) & 3  {
        case 0:
          computationValue += inputs[j]
        case 1:
          computationValue *= inputs[j]
        case 2:
          computationValue = concat(lhs: computationValue, rhs: inputs[j])
        default:
          preconditionFailure()
        }
      }
      if computationValue == target {
        return true
      }
    }
    return false
  }
  
  func part2b() async throws -> Int {
    var total = 0
    for (target, inputs) in Self.parseInput(data) {
      if validateLineP2(target: target, inputs: inputs) {
        total += target
      }
    }
    return total
  }
  
  func part2() async throws -> Int {
    try await part2a()
  }
  
  func part2c() async throws -> Int {
    var total = 0
    for (target, inputs) in Self.parseInput(data) {
      if validateLineP2c(target: target, inputs: inputs.dropFirst(0)) {
        total += target
      }
    }
    return total
  }
}

struct TernaryIterator : Sequence, IteratorProtocol {
  let digits: Int
  var current: Int
  var finished = false
  
//  init(start: Int, end: Int) {
//    self.countdown = countdown
//  }
  
  init(digits: Int) {
    self.digits = digits
    self.current = 0
    precondition(digits < 30)
  }
  
  @inline(__always)
  mutating func next() -> Int? {
    if finished { return nil }
    let retval = current
    current.ternaryIncrement()
    if (current >> (digits << 1)) > 0 {
      finished = true
    }
    return retval
  }
}

extension Int {
  func tit(_ tit: Int) -> Int {
    var result = self
    for _ in 0..<tit {
      result /= 3
    }
    return result % 3
  }
  
  static func maxTernery(forTits: Int) -> Int {
    3.raiseToPower(forTits)
  }
  
  /// Assumes existing value is ternary (one digit per 2 bits)
  @inline(__always)
  mutating func ternaryIncrement() {
    var result = self
    var mask = 3
    var increment = 1
    for digit in 0..<30 {
      let currentTDigit = (result & mask) >> (digit << 1)
      if currentTDigit != 2 {
        self = result + increment
        return
      }
      result -= (2 * increment)
      increment <<= 2
      mask <<= 2
    }
    self = -1
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day07 {}
