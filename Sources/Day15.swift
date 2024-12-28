import Foundation

struct Day15: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 15
  let puzzleName: String = "--- Day 15: Warehouse Woes! ---"

  init(data: String) {
    self.data = data
  }
  
  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  
  enum WareHouseSlotContent: Equatable, CustomStringConvertible {
    case empty
    case box
    case wall
    
    enum Error : Swift.Error {
      case invalidCharacter, robot
    }
    
    init (_ char: Character) throws {
      switch char {
      case ".": self = .empty
      case "#": self = .wall
      case "O": self = .box
      case "@": throw Error.robot
      default: throw Error.invalidCharacter
      }
    }
    
    var description: String {
      switch self {
      case .box: return "O"
      case .empty: return "."
      case .wall: return "#"
      }
    }
  }

  static func parseInput(data: String) throws -> (Grid<WareHouseSlotContent>, [Direction], Cord2D) {
    let lines = data.lines
    var iter = lines.makeIterator()
    var line = iter.next()
    var mapLines: [[WareHouseSlotContent]] = []
    var rowNumber: Int = 0
    var start: Cord2D?
    while line!.hasPrefix("#") {
      var row: [WareHouseSlotContent] = []
      for (char, column) in zip(line!, 0...) {
        do {
          try row.append(.init(char))
        } catch WareHouseSlotContent.Error.robot {
          row.append(.empty)
          start = .init(column, rowNumber)
        }
      }
      rowNumber += 1
      line = iter.next()
      mapLines.append(row)
    }
    var directions: [Direction] = []
    while line != nil {
      for char in line! {
        switch char {
        case "^": directions.append(.n)
        case "v": directions.append(.s)
        case "<": directions.append(.w)
        case ">": directions.append(.e)
        default: break
        }
      }
      line = iter.next()
    }
    
    return try (Grid(data: mapLines), directions, start!)
  }
  
  func computeTotal(map: Grid<WareHouseSlotContent>) -> Int {
    map.indexes(of: .box).map { 100 * $0.y + $0.x }.reduce(0, +)
  }
  
  func attemptMoveBox(warehouseMap: inout Grid<WareHouseSlotContent>, boxLocation: Cord2D, direction: Direction) -> Bool {
    let targetLocation = boxLocation + direction.offsetCord
    switch warehouseMap[targetLocation] {
    case .empty:
      warehouseMap[targetLocation] = .box
      return true
    case .box:
      if attemptMoveBox(warehouseMap: &warehouseMap, boxLocation: targetLocation, direction: direction) {
        warehouseMap[targetLocation] = .box
        return true
      } else {
        return false
      }
    case .wall:
      return false
    case .none:
      preconditionFailure()
    }
  }
  
  func attemptMove(warehouseMap: inout Grid<WareHouseSlotContent>, robotLocation: inout Cord2D, direction: Direction) {
    let targetLocation = robotLocation + direction.offsetCord
    switch warehouseMap[targetLocation] {
    case .empty:
      robotLocation = targetLocation
    case .box:
      if attemptMoveBox(warehouseMap: &warehouseMap, boxLocation: targetLocation, direction: direction) {
        warehouseMap[targetLocation] = .empty
        robotLocation = targetLocation
      }
    case .wall:
      break
    case .none:
      preconditionFailure()
    }
  }
  
  func doPart1(data: String) throws -> Int {
    var (warehouseMap, instructions, robotLocation) = try Self.parseInput(data: data)
    
    for instruction in instructions {
      attemptMove(warehouseMap: &warehouseMap, robotLocation: &robotLocation, direction: instruction)
      //print(warehouseMap)
    }
    
    return computeTotal(map: warehouseMap)
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    try doPart1(data: data)
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day15 {}
