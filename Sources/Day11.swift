import Foundation

struct Day11: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 11
  let puzzleName: String = "--- Day 11: Plutonian Pebbles! ---"

  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  init(data: String) {
    self.data = data
  }

  static func parseInput(data: String) -> [Int] {
    data.split(separator: " ").compactMap { Int($0) }
  }
  
  
  
  func counts(from: Int, blinks: Int) -> [Int] {
    var result: [Int] = .init(repeating: -1, count: blinks + 1)
    result[0] = 1
    var currentArray = [from]
    var runningTotal: Int = 0
    for i in 1...blinks {
      let fullNext = currentArray.flatMap(updateStone)
      currentArray = fullNext.filter { $0 != from }
      runningTotal += fullNext.count - currentArray.count
      result[i] = fullNext.count
//      print("\(i): \(result[i]) running: \(runningTotal) - \(currentArray.count))")
    }
    return result
  }
  
  func updateStone(_ stone: Int) -> [Int] {
    if stone == 0 {
      return [1]
    } else if let split = stone.digitSplitIfEven {
      return split
    } else {
      return [stone * 2024]
    }
  }
  
  func countForStone(stone: Int, alreadyComputed: inout [Cord2D:Int], blinks: Int) -> Int {
    let cord = Cord2D(stone, blinks)
    if blinks == 0 {
      return 1
    } else if let precalcResult = alreadyComputed[cord] {
      return precalcResult
    } else if stone == 0 {
      let result = countForStone(stone: 1, alreadyComputed: &alreadyComputed, blinks: blinks - 1)
      alreadyComputed[cord] = result
      return result
    } else if let (l, r) = stone.digitSplitIfEven2 {
      let lTotal = countForStone(stone: l, alreadyComputed: &alreadyComputed, blinks: blinks - 1)
      let result = lTotal + countForStone(stone: r, alreadyComputed: &alreadyComputed, blinks: blinks - 1)
      alreadyComputed[cord] = result
      return result
    } else {
      let result = countForStone(stone: stone * 2024, alreadyComputed: &alreadyComputed, blinks: blinks - 1)
      alreadyComputed[cord] = result
      return result
    }
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    var stones = Self.parseInput(data: data)
    for _ in 1...25 {
      stones = stones.flatMap(updateStone)
    }
    return stones.count
  }
  
  func part2() async throws -> Int {
    let blinks = 75
//    for i in 0..<blinks {
//      let result = countForStone(stone: 0, alreadyComputed: &memoised, blinks: i))
//      print("Blink \(i): \(result[i])")
//    }
    
    let stones = Self.parseInput(data: data)
    return await withTaskGroup(of: Int.self) { group in
      for stone in stones {
        group.addTask {
          var memoised: [Cord2D:Int] = [:]
//          defer { print(memoised.count) }
          return countForStone(stone: stone, alreadyComputed: &memoised, blinks: blinks)
        }
      }
      return await group.reduce(0, +)
    }
  }
}

extension Int {
  var digitSplitIfEven: [Int]? {
    var digits: [Int] = []
    var remaining = self
    while remaining > 0 {
      digits.append(remaining % 10)
      remaining /= 10
    }
    let count = digits.count
    if count.isMultiple(of: 2) {
      return [digits[(count/2)..<count].reversed().reduce(0){ ($0 * 10) + $1 },
              digits[0..<(count/2)].reversed().reduce(0){ ($0 * 10) + $1 }]
    } else {
      return nil
    }
  }
  
  var digitSplitIfEven2: (Int, Int)? {
    var remaining = self
    var digits: [Int] = []
    while remaining > 0 {
      digits.append(remaining % 10)
      remaining /= 10
    }
    let count = digits.count
    if count.isMultiple(of: 2) {
      return (digits[(count/2)..<count].reversed().reduce(0){ ($0 * 10) + $1 },
              digits[0..<(count/2)].reversed().reduce(0){ ($0 * 10) + $1 })
    } else {
      return nil
    }
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day11 {}
