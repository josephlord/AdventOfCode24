import Foundation
import RegexBuilder

struct Day14: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 14
  let puzzleName: String = "--- Day 14: Restroom Redoubt! ---"

  init(data: String) {
    self.data = data
  }
  
  init(rawData: [UInt8]) {
    preconditionFailure()
  }

  struct RobotInfo {
    var startPoint: Cord2D
    var velocity: Cord2D
    mutating func next(width: Int, height: Int) {
      startPoint = .init(
        (startPoint.x + velocity.x) % width,
        (startPoint.y + velocity.y) % height)
    }
  }
  
  static func parseInput(_ input: String) -> [RobotInfo] {
    let regex = Regex {
      "p="
      TryCapture {
        OneOrMore(.digit)
      } transform: { Int($0) }
      ","
      TryCapture {
        OneOrMore(.digit)
      } transform: { Int($0) }
      " v="
      TryCapture {
        Regex {
          Optionally {
            "-"
          }
          OneOrMore(.digit)
        }
      } transform: { Int($0) }
      ","
      TryCapture {
        Regex {
          Optionally {
            "-"
          }
          OneOrMore(.digit)
        }
      } transform: { Int($0) }
    }
    return input.matches(of: regex).map {
      .init(startPoint: .init($0.output.1, $0.output.2), velocity: .init($0.output.3, $0.output.4))
    }
  }
  
  func convertToPosVectors(input: [RobotInfo], width: Int, height: Int) -> [RobotInfo] {
    var result = input
    for i in result.indices {
      if input[i].velocity.x < 0 {
        result[i].velocity.x = input[i].velocity.x + width
      }
      if input[i].velocity.y < 0 {
        result[i].velocity.y = input[i].velocity.y + height
      }
    }
    return result
  }
  
  func part1() async throws -> Int {
    doPart1(data: data, width: 101, height: 103, seconds: 100)
  }
  
  func doPart1(data: String, width: Int, height: Int, seconds: Int) -> Int {
    let input = Self.parseInput(data)
    let positiveVectors = convertToPosVectors(input: input, width: width, height: height)
    var counts: [Cord2D.Quadrant: Int] = [:]
    
    for robot in positiveVectors {
      let totalOffset = robot.startPoint + (robot.velocity * seconds)
      let shiftedPosition = Cord2D(totalOffset.x % width, totalOffset.y % height)
      if let quadrant = shiftedPosition.quadrant(width: width, height: height) {
        counts[quadrant, default: 0] += 1
      }
    }
    
    return counts.values.reduce(1) { $0 * $1 }
  }
  
  func part2() async throws -> Int {
    try doPart2(data: data, width: 101, height: 103)
  }
  
  func doPart2(data: String, width: Int, height: Int) throws -> Int {
    let robots = Self.parseInput(data)
    var positiveRobots = convertToPosVectors(input: robots, width: width, height: height)
    let emptyGrid = try Grid(data: .init(repeating: .init(repeating: 0, count: width), count: height))
    var seconds = 0
    var populatedGrid = emptyGrid
    while true {
      var hasMultipleRobotsInLoc = false
      populatedGrid = emptyGrid
      for robot in positiveRobots {
        if (populatedGrid[robot.startPoint] ?? 0) > 0 {
          hasMultipleRobotsInLoc = true
        }
        populatedGrid[robot.startPoint] = (populatedGrid[robot.startPoint] ?? 0) + 1
      }
      
      if !hasMultipleRobotsInLoc {
        print(populatedGrid.descriptionBlankZeros)
        print(seconds)
        return 0
      }
      seconds += 1
      for i in positiveRobots.indices {
        positiveRobots[i].next(width: width, height: height)
      }
    }
    return 0
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day14 {}

extension Cord2D {
  enum Quadrant {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
  }
  func quadrant(width: Int, height: Int) -> Quadrant? {
    let isTop = y < height / 2
    let isLeft = x < width / 2
    if x == width / 2 || y == height / 2 {
      return nil
    }
    switch (isTop, isLeft) {
      case (true, true): return .topLeft
    case (true, false): return .topRight
    case (false, true): return .bottomLeft
    case (false, false): return .bottomRight
    }
  }
}
