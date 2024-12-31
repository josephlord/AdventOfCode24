//
//  Cord2D.swift
//  AdventOfCode
//
//  Created by Joseph Lord on 28/12/2024.
//

struct Cord2D : Hashable, Sendable, Equatable {
  var x: Int
  var y: Int
  
  init(_ x: Int, _ y: Int) {
    self.x = x
    self.y = y
  }
  
  enum Error : Swift.Error {
    case invalidInput
  }
  
  init(string: String) throws {
    let cords = string.split(separator: ",")
    guard cords.count == 2,
          let x = Int(cords[0]),
          let y = Int(cords[1])
    else {
      throw Error.invalidInput
    }
    self.x = x
    self.y = y
  }
  
  init(substring: Substring) throws {
    let cords = substring.split(separator: ",")
    guard cords.count == 2,
          let x = Int(cords[0]),
          let y = Int(cords[1])
    else {
      throw Error.invalidInput
    }
    self.x = x
    self.y = y
  }
  
  func isInRange(width: Int, height: Int) -> Bool {
    x >= 0 && x < width && y >= 0 && y < height
  }
}

func -(lhs: Cord2D, rhs: Cord2D) -> Cord2D {
  return Cord2D(lhs.x - rhs.x, lhs.y - rhs.y)
}

func +(lhs: Cord2D, rhs: Cord2D) -> Cord2D {
  return Cord2D(lhs.x + rhs.x, lhs.y + rhs.y)
}

extension Cord2D : CustomStringConvertible {
  var description: String {
    "(\(x),\(y))"
  }
}
