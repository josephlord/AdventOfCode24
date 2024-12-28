//
//  Grid.swift
//  AdventOfCode
//
//  Created by Joseph Lord on 13/12/2024.
//

extension Grid: Sendable where Element: Sendable {}

enum Direction: Equatable, CaseIterable {
  case n, s, e, w, ne, se, sw, nw
  var offset: (Int, Int) {
    switch self {
    case .n: return (0, -1)
    case .s: return (0, 1)
    case .e: return (1, 0)
    case .w: return (-1, 0)
    case .ne: return (1, -1)
    case .se: return (1, 1)
    case .sw: return (-1, 1)
    case .nw: return (-1, -1)
    }
  }
  
  var offsetCord: Cord2D {
    .init(tuple: self.offset)
  }
}

public struct Grid<Element> {
  
  enum GridError: Error {
    case invalidDimensions
  }
  
  private var data: [[Element]]
  let rows: Int
  let columns: Int
  
  init(data: [[Element]]) throws {
    columns = data.first?.count ?? 0
    for row in data {
      if row.count != columns {
        throw GridError.invalidDimensions
      }
    }
    self.data = data
    rows = data.count
  }
  
  func value(x: Int, y: Int, offset: Int = 1, inDirection: Direction) -> Element? {
    let computedX = x + inDirection.offset.0 * offset
    let computedY = y + inDirection.offset.1 * offset
    return self[computedX, computedY]
  }
  
  subscript(_ tuple: (Int, Int)) -> Element? {
    get {
      guard (0..<columns).contains(tuple.0) && (0..<rows).contains(tuple.1) else { return nil }
      return data[tuple.1][tuple.0]
    }
    set {
      guard let newValue, (0..<columns).contains(tuple.0) && (0..<rows).contains(tuple.1) else { return }
      data[tuple.1][tuple.0] = newValue }
  }
  
  subscript(_ x: Int, _ y: Int) -> Element? {
    get {
      guard (0..<columns).contains(x) && (0..<rows).contains(y) else { return nil }
      return data[y][x]
    }
    set {
      guard let newValue, (0..<columns).contains(x) && (0..<rows).contains(y) else { return }
      data[y][x] = newValue
    }
  }
  
}
extension Grid: CustomStringConvertible {
  public var description: String {
    data.map { line in line.map { "\($0)" }.joined() }
      .joined(separator: "\n")
  }
}

extension Grid where Element == Int {
  public var descriptionBlankZeros: String {
    data.map { line in line.map {
      switch $0 {
      case 0: return " "
      case 1...9: return "\($0)"
      case _ where $0 < 0: return "-"
      case _: return "#"
      }}.joined() }
        .joined(separator: "\n")
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
  
  func indexes(of: Element) -> [Cord2D] {
    
    var result = [Cord2D]()
    for y in 0..<rows {
      for x in 0..<columns {
        if self[(x, y)] == of {
          result.append(.init(x, y))
        }
      }
    }
    return result
  }
}

extension Grid {
  var flatArray: [Element] {
    data.flatMap { $0 }
  }
  
  func map<ResultType>(_ transform: (Element) throws -> ResultType) rethrows -> Grid<ResultType> {
    let newData = try data.map { line in try line.map { try transform($0) } }
    return try! Grid<ResultType>(data: newData)
  }
}


extension Grid {
  subscript (coord: Cord2D) -> Element? {
    get { self[coord.x, coord.y] }
    set { self[coord.x, coord.y] = newValue }
  }
}
