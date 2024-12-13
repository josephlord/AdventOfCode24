import Foundation

struct Day12: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 12
  let puzzleName: String = "--- Day 12: Garden Groups ---"

  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  init(data: String) {
    self.data = data
  }
  
  static func updateNeighbours(coord: Cord2D, inputGrid: Grid<Character>, resultGrid: inout Grid<(Int, Int)>, sizes: inout [Int]) {
    let currentVal = inputGrid[coord]!
    let id = resultGrid[coord]!.0
    
    for nextCoord in Direction.cardinalDirections.map({ coord + Cord2D(tuple: $0.offset) }) {
      if inputGrid[nextCoord] != currentVal {
        resultGrid[coord] = (id, resultGrid[coord]!.1 + 1)
      } else {
        if resultGrid[nextCoord]!.0 == -1 {
          sizes[id] += 1
          resultGrid[nextCoord] = (id, 0)
          updateNeighbours(coord: nextCoord, inputGrid: inputGrid, resultGrid: &resultGrid, sizes: &sizes)
        }
      }
    }
  }

  static func parseInput(_ input: String) -> (Grid<(Int,Int)>, [Int]) {
    let inputGrid = try! Grid(data: input.lines.map { line in line.map { $0 }})
    var resultGrid = try! Grid(data: Array(repeating: Array(repeating: (-1, 0), count: inputGrid.columns), count: inputGrid.rows))
    var sizes = [Int]()
    var id = 0
    for y in 0..<inputGrid.rows {
      for x in 0..<inputGrid.columns {
        if resultGrid[x,y]!.0 == -1 {
          resultGrid[x,y] = (id, 0)
          id += 1
          sizes.append(1)
          updateNeighbours(coord: Cord2D(x, y), inputGrid: inputGrid, resultGrid: &resultGrid, sizes: &sizes)
        }
      }
    }
    return (resultGrid, sizes)
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    let (grid, sizes) = Self.parseInput(data)
    var total = 0
    for y in 0..<grid.rows {
      for x in 0..<grid.columns {
        let (id, val) = grid[x,y]!
        total += val * sizes[id]
      }
    }
    return total
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day12 {}
