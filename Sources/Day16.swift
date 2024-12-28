import Foundation

struct Day16: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 16
  let puzzleName: String = "--- Day 16: Reindeer Maze ---"

  init(data: String) {
    self.data = data
  }
  
  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  enum MazeCell: Equatable {
    case empty
    case wall
    case visited([Direction: Int])
    case start
    case end(Int)
    
    init (_ character: Character) {
      switch character {
      case ".": self = .empty
      case "#": self = .wall
      case "S": self = .start
      case "E": self = .end(.max)
      default: preconditionFailure()
      }
    }
  }
  
  
  static func parseInput(data: String) throws -> Grid<MazeCell> {
    try .init(data: data.lines.map { line in line.map { MazeCell($0)} })
  }
  
  // Returns true if cell was updated so it can be added to the next pass
  func update(_ cell: Cord2D, score: Int, direction: Direction, maze: inout Grid<MazeCell>) -> Bool {
    switch maze[cell] {
    case .empty:
      maze[cell] = .visited([
        direction: score,
        direction.clockwise: score + 1000,
        direction.counterClockwise: score + 1000,
        direction.reversed: score + 2000])
      return true
    case .visited(let existingScores):
      if existingScores[direction]! <= score {
        return false
      }
      maze[cell] = .visited([
        direction: score,
        direction.clockwise: min(score + 1000, existingScores[direction.clockwise]!),
        direction.counterClockwise: min(score + 1000, existingScores[direction.counterClockwise]!),
        direction.reversed: min(score + 2000, existingScores[direction.reversed]!)
      ])
      return true
    case .wall:
      return false
    case .end(let bestScoreSoFar):
      maze[cell] = .end(min(bestScoreSoFar, score))
      return false
    case .start, .none:
      preconditionFailure()
    }
  }
  
  func updateNeighborsOf(_ cell: Cord2D, maze: inout Grid<MazeCell>) -> [Cord2D] {
    var needNeighborsUpdate: [Cord2D] = []
    switch maze[cell] {
    case .visited(let cellDictionary):
      for (key, value) in cellDictionary {
        let neighbour = cell + key.offsetCord
        if update(neighbour, score: value + 1, direction: key, maze: &maze) {
          needNeighborsUpdate.append(neighbour)
        }
      }
    default: preconditionFailure()
    }
    return needNeighborsUpdate
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    var maze = try Self.parseInput(data: data)
    let end = maze.firstIndex(of: .end(.max))!
    let start = Cord2D(tuple: maze.firstIndex(of: .start)!)
    var cellsToUpdateNeighborsOf = Set([start])
    maze[start] = .visited([.e:0, .w: 2000, .n: 1000, .s: 1000])
    while !cellsToUpdateNeighborsOf.isEmpty {
      let cell = cellsToUpdateNeighborsOf.removeFirst()
      cellsToUpdateNeighborsOf.formUnion( updateNeighborsOf(cell, maze: &maze))
    }
    
    switch maze[end] {
      case .end(let score): return score
    default: preconditionFailure()
    }
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day16 {}
