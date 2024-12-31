import Foundation

struct Day18: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 18
  let puzzleName: String = "--- Day 18: RAM Run ---"

  init(data: String) {
    self.data = data
  }
  
  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  enum MemoryElement : Equatable, CustomStringConvertible {
    case distance(Int)
    case unsafe
    case empty
    
    func distance() throws -> Int {
      switch self {
      case .distance(let distance): return distance
      case .unsafe: throw Error.unsafe
      case .empty: throw Error.empty
      }
    }
    
    enum Error : Swift.Error {
      case empty, unsafe
    }
    
    var description: String {
      switch self {
      case .distance(let distance): return " \(distance) "
      case .unsafe: return "  #  "
      case .empty: return "  .  "
      }
    }
  }
  
  static func parseInputToCordArray(_ input: String) throws -> [Cord2D] {
    try input.lines.map { try Cord2D(substring: $0) }
  }
  
  func gridFor(_ sequence: Array<Cord2D>.SubSequence, gridSize: Int) throws -> Grid<MemoryElement> {
    var grid = try Grid<MemoryElement>(data: .init(repeating: .init(repeating: .empty, count: gridSize), count: gridSize))
    for cord in sequence {
      grid[cord] = .unsafe
    }
    return grid
  }
  
  static func parseInput(_ input: String, gridSize: Int, addressCount: Int) throws -> Grid<MemoryElement> {
    var grid = try Grid<MemoryElement>(data: .init(repeating: .init(repeating: .empty, count: gridSize), count: gridSize))
    for line in input.lines.prefix(addressCount) {
      try grid[Cord2D(substring: line)] = .unsafe
    }
    return grid
  }

  func doPart1(input: String, gridSize: Int, addressCount: Int) throws -> Int {
    var grid = try Self.parseInput(input, gridSize: gridSize, addressCount: addressCount)
    grid[.init(0, 0)] = .distance(0)
    var cellsToUpdateNeighboursOf: Set<Cord2D> = [.init(0, 0)]
    while !cellsToUpdateNeighboursOf.isEmpty {
      let cellToUpdate = cellsToUpdateNeighboursOf.removeFirst()
      var distance = try grid[cellToUpdate]!.distance()
      for offsetCord in Direction.cardinalDirections.map( { cellToUpdate + $0.offsetCord } ) {
        let element = grid[offsetCord]
        switch element {
        case .distance(let dist) where dist >= distance - 1 && dist <= distance + 1:
          fallthrough
        case nil, .unsafe:
          break
        case .distance(let distanceToUpdate) where distanceToUpdate > distance + 1:
          fallthrough
        case .empty:
          grid[offsetCord] = .distance(distance + 1)
          cellsToUpdateNeighboursOf.insert(offsetCord)
        case .distance(let dist):
          distance = dist + 1
          grid[cellToUpdate] = .distance(distance)
          cellsToUpdateNeighboursOf.insert(cellToUpdate)
        }
      }
    }
    
    return try grid[.init(gridSize - 1, gridSize - 1)]!.distance()
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> String {
    try doPart1(input: data, gridSize: 71, addressCount: 1024).description
  }
  
  func gridHasPath(grid: Grid<MemoryElement>) -> Bool {
    var grid = grid
    grid[.init(0, 0)] = .distance(0)
    var cellsToUpdateNeighboursOf: Set<Cord2D> = [.init(0, 0)]
    let target = Cord2D(grid.columns - 1, grid.rows - 1)
    while !cellsToUpdateNeighboursOf.isEmpty {
      let cellToUpdate = cellsToUpdateNeighboursOf.removeFirst()
      for offsetCord in Direction.cardinalDirections.map( { cellToUpdate + $0.offsetCord } ) {
        if offsetCord == target {
          return true
        }
        let element = grid[offsetCord]
        switch element {
        case .distance, nil, .unsafe:
          break
        case .empty:
          grid[offsetCord] = .distance(0)
          cellsToUpdateNeighboursOf.insert(offsetCord)
        }
      }
    }
    return false
  }
  
  func doPart2(gridsize: Int) throws -> (Cord2D, Int) {
    var knownGood = 0
    let cordAray = try Self.parseInputToCordArray(data)
    var knownBad = cordAray.count
    while knownBad - knownGood > 1 {
      let inputSize = (knownBad + knownGood) / 2
      let grid = try gridFor(cordAray.prefix(inputSize), gridSize: gridsize)
      if gridHasPath(grid: grid) {
        knownGood = inputSize
      } else {
        knownBad = inputSize
      }
      //print("\(knownGood) - \(knownBad)")
    }
    let result = knownGood
    return (cordAray[knownGood], knownGood)
  }
  
  func part2() async throws -> String {
    let gridsize = 71
    let (cord, knownBad) = try doPart2(gridsize: gridsize)
    return cord.description
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day18 {}
