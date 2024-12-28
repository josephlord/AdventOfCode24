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
    case boxLeft
    case boxRight
    
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
      case .boxLeft: return "["
      case .boxRight: return "]"
      }
    }
  }

  static func parseInput(data: String, part2: Bool = false) throws -> (Grid<WareHouseSlotContent>, [Direction], Cord2D) {
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
          let content = try WareHouseSlotContent(char)
          if part2 && content == .box {
            row.append(.boxLeft)
            row.append(.boxRight)
          } else {
            if part2 {
              row.append(content)
            }
            row.append(content)
          }
        } catch WareHouseSlotContent.Error.robot {
          row.append(.empty)
          if part2 {
            row.append(.empty)
            start = .init(column * 2, rowNumber)
          } else {
            start = .init(column, rowNumber)
          }
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
  
  func computeTotal2(map: Grid<WareHouseSlotContent>) -> Int {
    map.indexes(of: .boxLeft).map { 100 * $0.y + $0.x }.reduce(0, +)
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
    case .boxLeft, .boxRight:
      preconditionFailure()
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
    case .none, .boxLeft, .boxRight:
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
  
//  func checkMove(warehouseMap: Grid<WareHouseSlotContent>, fromLocation: Cord2D, direction: Direction) -> Bool {
//    let targetLocation = fromLocation + direction.offsetCord
//    return switch (warehouseMap[targetLocation], [.n, .s].contains(direction)) {
//    case (.empty, _):
//      true
//    case (.boxLeft, true):
//      checkMove(warehouseMap: warehouseMap, fromLocation: targetLocation, direction: direction)
//      && checkMove(warehouseMap: warehouseMap, fromLocation: targetLocation + Direction.e.offsetCord, direction: direction)
//    case (.boxRight, true):
//      checkMove(warehouseMap: warehouseMap, fromLocation: targetLocation, direction: direction)
//      && checkMove(warehouseMap: warehouseMap, fromLocation: targetLocation + Direction.w.offsetCord, direction: direction)
//    case (.boxRight, false), (.boxLeft, false):
//      checkMove(warehouseMap: warehouseMap, fromLocation: targetLocation + direction.offsetCord, direction: direction)
//    case (.wall, _):
//      false
//    case (.box, _), (.none, _):
//      preconditionFailure()
//    }
//  }
  
  enum WarehouseError : Error {
    case wall
  }
  
  func moveIfNecessary(warehouseMap: inout Grid<WareHouseSlotContent>, locationToMove: Cord2D, direction: Direction) throws {
    switch (warehouseMap[locationToMove], [.n, .s].contains(direction)) {
      case (.empty, _):
      break
    case (.wall, _):
      throw WarehouseError.wall
    case (.boxLeft, false), (.boxRight, false):
      try moveIfNecessary(
        warehouseMap: &warehouseMap,
        locationToMove: locationToMove + direction.offsetCord + direction.offsetCord,
        direction: direction)
      warehouseMap[locationToMove + direction.offsetCord + direction.offsetCord] = warehouseMap[locationToMove + direction.offsetCord]
      warehouseMap[locationToMove + direction.offsetCord] = warehouseMap[locationToMove]
      warehouseMap[locationToMove] = .empty
    case (.boxLeft, true):
      try moveIfNecessary(
        warehouseMap: &warehouseMap,
        locationToMove: locationToMove + direction.offsetCord,
        direction: direction)
      try moveIfNecessary(
        warehouseMap: &warehouseMap,
        locationToMove: locationToMove + direction.offsetCord + Direction.e.offsetCord,
        direction: direction)
      warehouseMap[locationToMove + direction.offsetCord] = .boxLeft
      warehouseMap[locationToMove + direction.offsetCord + Direction.e.offsetCord] = .boxRight
      warehouseMap[locationToMove] = .empty
      warehouseMap[locationToMove + Direction.e.offsetCord] = .empty
    case (.boxRight, true):
      try moveIfNecessary(
        warehouseMap: &warehouseMap,
        locationToMove: locationToMove + direction.offsetCord,
        direction: direction)
      try moveIfNecessary(
        warehouseMap: &warehouseMap,
        locationToMove: locationToMove + direction.offsetCord + Direction.w.offsetCord,
        direction: direction)
      warehouseMap[locationToMove + direction.offsetCord] = .boxRight
      warehouseMap[locationToMove + direction.offsetCord + Direction.w.offsetCord] = .boxLeft
      warehouseMap[locationToMove] = .empty
      warehouseMap[locationToMove + Direction.w.offsetCord] = .empty
    default:
      preconditionFailure()
    }
  }
  
  func attemptMove2(warehouseMap: inout Grid<WareHouseSlotContent>, robotLocation: inout Cord2D, direction: Direction) {
    do {
      let targetLocation = robotLocation + direction.offsetCord
      var mapCopy = warehouseMap
      try moveIfNecessary(warehouseMap: &mapCopy, locationToMove: targetLocation, direction: direction)
      warehouseMap = mapCopy
      robotLocation = targetLocation
    } catch WarehouseError.wall {
      return
    } catch {
      preconditionFailure()
    }
  }
  
  func doPart2(data: String) throws -> Int {
    var (warehouseMap, instructions, robotLocation) = try Self.parseInput(data: data, part2: true)
    
    for instruction in instructions {
      attemptMove2(warehouseMap: &warehouseMap, robotLocation: &robotLocation, direction: instruction)
//      print(warehouseMap)
    }
    
    return computeTotal2(map: warehouseMap)
  }
  func part2() async throws -> Int {
    try doPart2(data: data)
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day15 {}
