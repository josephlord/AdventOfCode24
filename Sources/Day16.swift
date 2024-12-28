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
    case end([Direction: Int])
    
    init (_ character: Character) {
      switch character {
      case ".": self = .empty
      case "#": self = .wall
      case "S": self = .start
      case "E": self = .end([.n:.max, .s:.max, .w:.max, .e:.max])
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
    case .end(let bestScoresSoFar):
      if bestScoresSoFar[direction]! <= score {
        return false
      }
      maze[cell] = .end([
        direction: score,
        direction.clockwise: min(score + 1000, bestScoresSoFar[direction.clockwise]!),
        direction.counterClockwise: min(score + 1000, bestScoresSoFar[direction.counterClockwise]!),
        direction.reversed: min(score + 2000, bestScoresSoFar[direction.reversed]!)
      ])
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
  
  func calculatePathsToEnd() throws -> (Grid<MazeCell>, Cord2D) {
    var maze = try Self.parseInput(data: data)
    let end = maze.firstIndex(of: .end([.n:.max, .s:.max, .e:.max, .w:.max]))!
    let start = Cord2D(tuple: maze.firstIndex(of: .start)!)
    var cellsToUpdateNeighborsOf = Set([start])
    maze[start] = .visited([.e:0, .w: 2000, .n: 1000, .s: 1000])
    while !cellsToUpdateNeighborsOf.isEmpty {
      let cell = cellsToUpdateNeighborsOf.removeFirst()
      cellsToUpdateNeighborsOf.formUnion( updateNeighborsOf(cell, maze: &maze))
    }
    return (maze, Cord2D(tuple: end))
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    let (maze, end) = try calculatePathsToEnd()
    
    switch maze[end] {
    case .end(let scores): return scores.values.min()!
    default: preconditionFailure()
    }
  }
  
  func addEnrouteCells(_ cell: Cord2D, direction: Direction, targetScore: Int, maze: Grid<MazeCell>, enrouteCells: inout Set<Cord2D>) {
    let revDir = direction.reversed
    enrouteCells.insert(cell)
    let nextNeighbour = cell + revDir.offsetCord
    switch maze[nextNeighbour] {
    case .visited(let scores):
      if scores[direction] == targetScore - 1 {
        addEnrouteCells(nextNeighbour, direction: direction, targetScore: targetScore - 1, maze: maze, enrouteCells: &enrouteCells)
      }
    default: break
    }
    let cw = direction.clockwise
    let ccw = direction.counterClockwise
    let cwNeighbour = cell + cw.offsetCord
    switch maze[cwNeighbour] {
    case .visited(let scores):
      if scores[ccw] == targetScore - 1001 {
        addEnrouteCells(cwNeighbour, direction: ccw, targetScore: targetScore - 1001, maze: maze, enrouteCells: &enrouteCells)
      }
    default: break
    }
    let ccwNeighbour = cell + ccw.offsetCord
    switch maze[ccwNeighbour] {
    case .visited(let scores):
      if scores[cw] == targetScore - 1001 {
        addEnrouteCells(ccwNeighbour, direction: cw, targetScore: targetScore - 1001, maze: maze, enrouteCells: &enrouteCells)
      }
    default: break
    }
    
    
  }
  
  func part2() async throws -> Int {
    let (maze, end) = try calculatePathsToEnd()
    var enrouteCells: Set<Cord2D> = []
    switch maze[end] {
    case .end(let endScores):
      let endScore = endScores.values.min()!
      let directions = endScores.compactMap { (direction, value) in value == endScore ? direction : nil }
      for direction in directions {
        addEnrouteCells(end, direction: direction, targetScore: endScore, maze: maze, enrouteCells: &enrouteCells)
      }
    default: preconditionFailure()
    }
    return enrouteCells.count
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day16 {}
