import Foundation

struct Day10: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 10
  let puzzleName: String = "--- Day 0: Placeholder! ---"
  
  init(rawData: [UInt8]) {
    self.data = ""
    preconditionFailure()
  }
  
  init(data: String) {
    self.data = data
    
  }
  
  static func parseInput(data: String) throws -> (Grid<UInt8>, [Cord2D]) {
    var cords: [Cord2D] = []
    var x: Int = 0
    var y: Int = 0
    let array = data.lines.map { line in
      x = 0
      let result = line.compactMap {
        let val = UInt8($0.description)
        if val == 0 {
          cords.append(Cord2D(x, y))
        }
        x += 1
        return val
      }
      y += 1
      return result
    }
    return try! (.init(data: array), cords)
  }
  
  func endpointsFrom(grid: Grid<UInt8>, from: Cord2D) -> Set<Cord2D> {
    switch grid[from] {
    case 9:
      return [from]
    case let level?:
      let nextSteps = Direction.cardinalDirections
        .map { from + Cord2D(tuple: $0.offset) }
        .filter { grid[$0] == level + 1 }
      return nextSteps.reduce(Set<Cord2D>(), { $0.union(endpointsFrom(grid: grid, from: $1)) })
    default:
      preconditionFailure()
    }
  }
  
  func trailsFrom(grid: Grid<UInt8>, from: Cord2D) -> Int {
    switch grid[from] {
    case 9:
      return 1
    case let level?:
      let nextSteps = Direction.cardinalDirections
        .map { from + Cord2D(tuple: $0.offset) }
        .filter { grid[$0] == level + 1 }
      return nextSteps.reduce(0, { $0 + (trailsFrom(grid: grid, from: $1)) })
    default:
      preconditionFailure()
    }
  }
  
  func countForGroup(grid: Grid<UInt8>, startPoint: Cord2D) -> Int {
    endpointsFrom(grid: grid, from: startPoint).count
  }
  
  func countForGroup2(grid: Grid<UInt8>, startPoint: Cord2D) -> Int {
    trailsFrom(grid: grid, from: startPoint)
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    let (grid, startPoints) = try Self.parseInput(data: data)
    return await withTaskGroup(of: Int.self) { group in
      for start in startPoints {
        group.addTask {
          countForGroup(grid: grid, startPoint: start)
        }
      }
      return await group.reduce(0, +)
    }
  }
  
  func part2() async throws -> Int {
    try await part2a()
  }
  
  func part2a() async throws -> Int {
    let (grid, startPoints) = try Self.parseInput(data: data)
    return await withTaskGroup(of: Int.self) { group in
      for start in startPoints {
        group.addTask {
          countForGroup2(grid: grid, startPoint: start)
        }
      }
      return await group.reduce(0, +)
    }
  }
}

extension Direction {
  static var cardinalDirections: [Direction] {
    [.n, .e, .s, .w]
  }
}

extension Cord2D {
  init (tuple: (Int, Int)) {
    self.x = tuple.0
    self.y = tuple.1
  }
}

extension Grid {
  subscript (coord: Cord2D) -> Element? {
    get { self[coord.x, coord.y] }
    set { self[coord.x, coord.y] = newValue }
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day10 {}
