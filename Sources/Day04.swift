import Foundation



fileprivate enum GridValue: Equatable, Sendable {
  case other, x, m, a, s
  
  init (_ character: Character) {
    switch character {
    case "X": self = .x
    case "M": self = .m
    case "A": self = .a
    case "S": self = .s
    default: self = .other
    }
  }
}

struct Day04: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 0
  let puzzleName: String = "--- Day 4: Placeholder! ---"
  fileprivate let grid: Grid<GridValue>
  
  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  init(data: String) {
    self.data = data
    grid = try! Self.parseInput1(data: data)
  }

  fileprivate static func parseInput1(data: String) throws -> Grid<GridValue> {
    try .init(data: data.lines.map { $0.map { GridValue($0) } })
  }
  
  func checkMAS(x: Int, y: Int, direction: Direction) -> Int {
    if grid.value(x: x, y: y, offset: 3, inDirection: direction) == .s,
       grid.value(x: x, y: y, offset: 2, inDirection: direction) == .a,
       grid.value(x: x, y: y, offset: 1, inDirection: direction) == .m {
      return 1
    } else {
      return 0
    }
  }
  
  func checkMasAllDirections(x: Int, y: Int) -> Int {
    Direction.allCases.reduce(0) { result, direction in
      result + checkMAS(x: x, y: y, direction: direction)
    }
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    var count = 0
    for x in 0..<grid.columns {
      for y in 0..<grid.rows {
        if grid[x, y] == .x {
          count += checkMasAllDirections(x: x, y: y)
        }
      }
    }
    return count
  }
  
  fileprivate func isMandS(l: GridValue?, r: GridValue?) -> Bool {
    switch (l, r) {
    case (.m, .s),
         (.s, .m):
      return true
    default:
      return false
    }
  }
  
  func checkMAS(x: Int, y: Int) -> Bool {
    if isMandS(l: grid.value(x: x, y: y, inDirection: .nw), r: grid.value(x: x, y: y, inDirection: .se)),
       isMandS(l: grid.value(x: x, y: y, inDirection: .ne), r: grid.value(x: x, y: y, inDirection: .sw)) {
      return true
    } else {
      return false
    }
  }
  
  func part2() async throws -> Int {
    var count = 0
    for x in 1..<(grid.columns - 1) {
      for y in 1..<(grid.rows - 1) {
        if grid[x, y] == .a,
           checkMAS(x: x, y: y)
        {
          count += 1
        }
      }
    }
    return count
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day04 {}
