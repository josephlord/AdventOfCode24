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
  
  static func updateNeighbours2Fail(coord: Cord2D, inputGrid: Grid<Character>, resultGrid: inout Grid<(Int, [Direction], Int)>, sizes: inout [Int]) {
    let currentVal = inputGrid[coord]!
    let id = resultGrid[coord]!.0
    sizes[id] += 1
//    print("(\(coord.x),\(coord.y) -> \(id))")
    let (edges, nextOptions, existingEdges) = Direction.cardinalDirections.reduce(([Direction](),[Direction](),Set<Direction>())) { directionArrays, direction in
      
      let tryingCoord = coord + Cord2D(tuple: direction.offset)
      if resultGrid[tryingCoord]?.0 == id  {
        var updatedExistingEdges = directionArrays.2
        updatedExistingEdges.formUnion( resultGrid[tryingCoord]?.1 ?? [])
        return (directionArrays.0, directionArrays.1, updatedExistingEdges)
      } else if inputGrid[tryingCoord] == currentVal {
        var nextOptions = directionArrays.1
        nextOptions.append(direction)
        return (directionArrays.0, nextOptions, directionArrays.2)
      } else {
        var edges = directionArrays.0
        edges.append(direction)
        return (edges, directionArrays.1, directionArrays.2)
      }
    }
    
    let newEdges = edges.filter { !existingEdges.contains($0) }
    resultGrid[coord] = (id, edges, newEdges.count)
    
    for nextDirection in nextOptions {
      let nextCoord = coord + Cord2D(tuple: nextDirection.offset)
      guard resultGrid[nextCoord]?.0 == -1 else { continue }
      resultGrid[nextCoord] = (id, [], 0)
      updateNeighbours2Fail(coord: nextCoord, inputGrid: inputGrid, resultGrid: &resultGrid, sizes: &sizes)
    }
  }

  static func parseInput2Fail(_ input: String) -> (Grid<(Int, [Direction] ,Int)>, [Int]) {
    let inputGrid = try! Grid(data: input.lines.map { line in line.map { $0 }})
    var resultGrid = try! Grid(data: Array(repeating: Array(repeating: (-1, [Direction](), 0), count: inputGrid.columns), count: inputGrid.rows))
    var sizes = [Int]()
    var id = 0
    for y in 0..<inputGrid.rows {
      for x in 0..<inputGrid.columns {
        if resultGrid[x,y]!.0 == -1 {
          resultGrid[x,y] = (id, [], 0)
          id += 1
          sizes.append(0)
          updateNeighbours2Fail(coord: Cord2D(x, y), inputGrid: inputGrid, resultGrid: &resultGrid, sizes: &sizes)
        }
      }
    }
    return (resultGrid, sizes)
  }
  
  static func updateNeighbours2(coord: Cord2D, inputGrid: Grid<Character>, resultGrid: inout Grid<Int>, sizes: inout [Int]) {
    let currentVal = inputGrid[coord]!
    let id = resultGrid[coord]!
    sizes[id] += 1
    let nextOptions = Direction.cardinalDirections.filter { direction in
      let tryingCoord = coord + Cord2D(tuple: direction.offset)
      return resultGrid[tryingCoord] == -1 &&
         inputGrid[tryingCoord] == currentVal
    }
    for nextDirection in nextOptions {
      let nextCoord = coord + Cord2D(tuple: nextDirection.offset)
      guard resultGrid[nextCoord] == -1 else { continue }
      resultGrid[nextCoord] = id
      updateNeighbours2(coord: nextCoord, inputGrid: inputGrid, resultGrid: &resultGrid, sizes: &sizes)
    }
  }
  
  static func parseInput2(_ input: String) -> (Grid<Int>, [Int]) {
    let inputGrid = try! Grid(data: input.lines.map { line in line.map { $0 }})
    var resultGrid = try! Grid(data: Array(repeating: Array(repeating: -1, count: inputGrid.columns), count: inputGrid.rows))
    var sizes = [Int]()
    var id = 0
    for y in 0..<inputGrid.rows {
      for x in 0..<inputGrid.columns {
        if resultGrid[x,y] == -1 {
          resultGrid[x,y] = id
          id += 1
          sizes.append(0)
          updateNeighbours2(coord: Cord2D(x, y), inputGrid: inputGrid, resultGrid: &resultGrid, sizes: &sizes)
        }
      }
    }
    return (resultGrid, sizes)
  }
  
  func part2() async throws -> Int {
    let (grid, sizes) = Self.parseInput2(data)
    var total = 0
    let ew: Set<Direction> = [.e, .w]
    let ns: Set<Direction> = [.n, .s]
    
//    print(grid.map { $0 })
    
    var previousLineEW:[Set<Direction>] = .init(repeating: [], count: grid.columns)
    var currentLineEW:[Set<Direction>] = []
    for y in 0..<grid.rows {
      var previousNS: Set<Direction> = []
      for x in 0..<grid.columns {
        let (id) = grid[x,y]!
        let edges = Set(Direction.cardinalDirections.filter { direction in
          let tryingCoord = Cord2D(x, y) + Cord2D(tuple: direction.offset)
          return grid[tryingCoord] != id
        })
        var val = edges
        if grid[x-1,y] == id { val.subtract(previousNS) }
//        val.subtracting(previousNS)
        if grid[x, y-1] == id { val.subtract(previousLineEW[x]) }
//          .subtracting(previousLineEW[x]).count
        previousNS = edges.intersection(ns)
        currentLineEW.append(edges.intersection(ew))
        total += val.count * sizes[id]
      }
      
      previousLineEW = currentLineEW
      currentLineEW = []
    }
    return total
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day12 {}
