import Foundation

struct Day02: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 2
  let puzzleName: String = "--- Day 2: Placeholder! ---"

  init(data: String) {
    self.data = data
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    self.data.lines.count(where: isSafe)
  }
  
  func part2() async throws -> Int {
    self.data.lines.count(where: isSafeWithDroppedItem)
  }
  
  func isSafeWithDroppedItem(line: Substring) -> Bool {
    let levels = line.split(separator: " ", omittingEmptySubsequences: true).compactMap({Int($0)})
    for i in 0..<levels.count {
      var skipLevels = levels
      skipLevels.remove(at: i)
      if isSafe(line: skipLevels) {
        return true
      }
    }
    return false
  }
  
  func isSafe(line: [Int]) -> Bool {
    var isIncreasing: Bool?
    var lastValue: Int?
    for level in line {
      switch (isIncreasing, lastValue) {
      case (true, let previous?) where isSmallIncrease(previous: previous, current: level):
        lastValue = level
      case (false, let previous?) where isSmallDecreaase(previous: previous, current: level):
        lastValue = level
      case (nil, nil):
        lastValue = level
      case (nil, let previous?) where isSmallIncrease(previous: previous, current: level):
        isIncreasing = true
        lastValue = level
      case (nil, let previous?) where isSmallDecreaase(previous: previous, current: level):
        isIncreasing = false
        lastValue = level
      default:
        return false
      }
    }
    return true
  }
  
  func isSafe(line: Substring) -> Bool {
    isSafe(line: line.split(separator: " ", omittingEmptySubsequences: true).compactMap { Int($0) })
  }
}

func isSmallIncrease(previous: Int, current: Int) -> Bool {
  current > previous && current <= previous + 3
}

func isSmallDecreaase(previous: Int, current: Int) -> Bool {
  current < previous && current >= previous - 3
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day02 {}
