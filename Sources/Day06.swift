import Foundation

enum GuardMapCell {
  case visited, empty, obstruction, start, potentialObstruction, potentialObstructionVisited
  init (_ char: Character) {
    switch char {
    case "#": self = .obstruction
    case ".": self = .empty
    case "^": self = .start
    default:
      preconditionFailure()
    }
  }
}

extension GuardMapCell : CustomStringConvertible {
  var description: String {
    switch self {
    case .visited: return "X"
    case .empty: return "."
    case .obstruction: return "#"
    case .start: return "^"
    case .potentialObstruction: return "O"
    case .potentialObstructionVisited: return "O"
    }
  }
}

extension Direction {
  var guardNextDirection: Direction {
    switch self {
      case .n: return .e
      case .e: return .s
      case .s: return .w
      case .w: return .n
      default:
      preconditionFailure()
    }
  }
}

func +(lhs: (Int, Int), rhs: (Int, Int)) -> (Int, Int) {
  (lhs.0 + rhs.0, lhs.1 + rhs.1)
}

extension Grid where Element : Equatable {
  func firstIndex(of: Element) -> (Int, Int)? {
    for y in 0..<rows {
      for x in 0..<columns {
        if self[(x, y)] == of {
          return (x, y)
        }
      }
    }
    return nil
  }
}

fileprivate func key(_ tuple: (Int, Int)) -> Int {
  tuple.0 * 100000 + tuple.1
}

struct GuardState {
  var guardPosition: (Int, Int)?
  var guardDirection: Direction
  var grid: Grid<GuardMapCell>
  var visitedCount = 0
  var visited: [Int: Set<Direction>] = [:]
  var newObstructionCount = 0
  
  init(grid: Grid<GuardMapCell>) {
    self.grid = grid
    self.guardDirection = .n
    guardPosition = grid.firstIndex(of: .start)
    if let guardPosition {
      self.grid[guardPosition] = .visited
      visitedCount = 1
      visited[key(guardPosition)] = [guardDirection]
    }
  }
  
  /// returns true if still in bounds
  mutating func next() -> Bool {
    guard let guardPosition else { return false }
    let nextPosition = guardPosition + guardDirection.offset
    switch grid[nextPosition] {
      case .obstruction:
      guardDirection = guardDirection.guardNextDirection
      return next()
    case .empty:
      self.guardPosition = nextPosition
      visitedCount += 1
      grid[nextPosition] = .visited
    case nil:
      return false
    case .visited, .start:
      self.guardPosition = nextPosition
    case .potentialObstruction, .potentialObstructionVisited:
      preconditionFailure()
    }
    return true
  }
  
  mutating func pathLeadsToRepeat() -> Bool {
    while let guardPosition {
      if visited[key(guardPosition)]?.contains(guardDirection) ?? false {
        return true
      }
      visited[key(guardPosition), default: []].insert(guardDirection)
      let nextPosition = guardPosition + guardDirection.offset
      switch grid[nextPosition] {
      case .obstruction:
        guardDirection = guardDirection.guardNextDirection
        return pathLeadsToRepeat()
      case nil:
        return false
      default:
        self.guardPosition = nextPosition
      }
    }
    return false
  }
  
  /// returns true if still in bounds
  mutating func next2() -> Bool {
    guard let guardPosition else { return false }
    let nextPosition = guardPosition + guardDirection.offset
    let nextPosContent = grid[nextPosition]
    let startGuardPosition = guardPosition
    switch nextPosContent {
      case .obstruction:
      guardDirection = guardDirection.guardNextDirection
      visited[key(guardPosition), default: []].insert(guardDirection)
      return next2()
    case .empty, .visited, .start:
      self.guardPosition = nextPosition
      grid[nextPosition] = .visited
    case nil:
      return false
    case .potentialObstruction, .potentialObstructionVisited:
      self.guardPosition = nextPosition
      grid[nextPosition] = .potentialObstructionVisited
      
    }
    if .empty == nextPosContent {
      var copy = self
      copy.guardDirection = guardDirection.guardNextDirection
      copy.grid[nextPosition] = .obstruction
      copy.guardPosition = startGuardPosition
      if copy.pathLeadsToRepeat() {
        newObstructionCount += 1
        grid[nextPosition] = nextPosContent == .visited ? .potentialObstructionVisited : .potentialObstruction
      }
    }
    let key = key(nextPosition)
    visited[key, default: []].insert(guardDirection)
    return true
  }
}

struct Day06: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 6
  let puzzleName: String = "--- Day 6: Guard Gallivant! ---"

  init(data: String) {
    self.data = data
  }

  static func parseInput(_ input: String) -> Grid<GuardMapCell> {
    try! .init(data: input.lines.map { line in line.map { GuardMapCell($0) } })
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    var guardState = GuardState(grid: Self.parseInput(data))
    while guardState.next() {}
    return guardState.visitedCount
  }
  
  func part2() async throws -> Int {
    var guardState = GuardState(grid: Self.parseInput(data))
    while guardState.next2() {}
    return guardState.newObstructionCount
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day06 {}
