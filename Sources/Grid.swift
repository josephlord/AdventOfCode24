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
}