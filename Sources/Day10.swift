import Foundation

struct Day10: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 10
  let puzzleName: String = "--- Day 10: Hoof It  ---"
  let grid: Grid<UInt8>
  let startPoints: [Cord2D]
  let trailCountCache: RouteCountCache
  let destinationCountCache: DestinationCountCache
  
  init(rawData: [UInt8]) {
    self.data = ""
    preconditionFailure()
  }
  
  init(data: String) {
    self.data = data
    (grid, startPoints) = try! Self.parseInput(data: data)
    trailCountCache = RouteCountCache(width: grid.columns, height: grid.rows)
    destinationCountCache = DestinationCountCache(width: grid.columns, height: grid.rows)
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
    if let cached = destinationCountCache.value(forLocation: from) {
      return cached
    }
    switch grid[from] {
    case 9:
      return [from]
    case let level?:
      let nextSteps = Direction.cardinalDirections
        .map { from + Cord2D(tuple: $0.offset) }
        .filter { grid[$0] == level + 1 }
      
      let result = nextSteps.reduce(Set<Cord2D>(), { $0.union(endpointsFrom(grid: grid, from: $1)) })
      destinationCountCache.set(set: result, forLocation: from)
      return result
    default:
      preconditionFailure()
    }
  }
  
  final class RouteCountCache : @unchecked Sendable {
    private var grid: Grid<Int>
    init(width: Int, height: Int) {
      grid = try! .init(data: .init(repeating: .init(repeating: -1, count: width), count: height))
    }
    
    func set(count: Int, forLocation: Cord2D) {
      grid[forLocation] = count
    }
    
    func value(forLocation: Cord2D) -> Int? {
      let value = grid[forLocation]
      guard value ?? -1 >= 0 else { return nil }
      return value
    }
  }
  
  final class DestinationCountCache : @unchecked Sendable {
    private var grid: Grid<Set<Cord2D>?>
    init(width: Int, height: Int) {
      grid = try! .init(data: .init(repeating: .init(repeating: nil, count: width), count: height))
    }
    
    func set(set: Set<Cord2D>, forLocation: Cord2D) {
      grid[forLocation] = set
    }
    
    func value(forLocation: Cord2D) -> Set<Cord2D>? {
      return grid[forLocation] ?? nil
    }
  }
  
  func trailsFrom(grid: Grid<UInt8>, from: Cord2D) -> Int {
    if let cached = trailCountCache.value(forLocation: from) {
      return cached
    }
    
    switch grid[from] {
    case 9:
      return 1
    case let level?:
      let nextSteps = Direction.cardinalDirections
        .map { from + Cord2D(tuple: $0.offset) }
        .filter { grid[$0] == level + 1 }
      var total = 0
      for step in nextSteps
      {
        total += trailsFrom(grid: grid, from: step)
      }
      trailCountCache.set(count: total, forLocation: from)
      return total
    default:
      preconditionFailure()
    }
  }
  
  func countForGroup(grid: Grid<UInt8>, startPoint: Cord2D) -> Int {
    endpointsFrom(grid: grid, from: startPoint).count
  }
  
  func countForGroup2(grid: Grid<UInt8>, startPoint: Cord2D)  -> Int {
     trailsFrom(grid: grid, from: startPoint)
  }
  
  // Replace this with your solution for the first part of the day's challenge.
//  func part1() async throws -> Int {
//    let (grid, startPoints) = try Self.parseInput(data: data)
//    return await withTaskGroup(of: Int.self) { group in
//      for start in startPoints {
//        group.addTask {
//          countForGroup(grid: grid, startPoint: start)
//        }
//      }
//      return await group.reduce(0, +)
//    }
//  }
  
  func part1() async throws -> Int {
    let (grid, startPoints) = try Self.parseInput(data: data)
    var total = 0
    for start in startPoints {
        total += countForGroup(grid: grid, startPoint: start)
    }
    return total
  }
  
  func part2() async throws -> Int {
    
//    return await withTaskGroup(of: Int.self) { group in
//      for start in startPoints {
//        group.addTask {
//          await countForGroup2(grid: grid, startPoint: start)
//        }
//      }
//      return await group.reduce(0, +)
//    }
    var total = 0
    for start in startPoints {
      total +=  countForGroup2(grid: grid, startPoint: start)
    }
    return total
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
