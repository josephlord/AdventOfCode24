import Foundation
import RegexBuilder

struct Day08: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 8
  let puzzleName: String = "--- Day 8: Resonant Collinearity! ---"

  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  init(data: String) {
    self.data = data
  }

  static func parseInput(input: String) throws -> ([Character: [Cord2D]], Int, Int) {
    var result = [Character: [Cord2D]]()
    let lines = input.lines
    let height: Int = lines.count
    let width: Int = lines.first!.count
    for (y, line) in lines.enumerated() {
      for (x, char) in line.enumerated() {
        guard char != "." else { continue }
        precondition(char.isLetter || char.isNumber)
        result[char, default: []].append(Cord2D(x, y))
      }
    }
    return (result, width, height)
  }
  
  func antiNodes(nodeL: Cord2D, nodeR: Cord2D, height: Int, width: Int) -> [Cord2D] {
    let vector = nodeR - nodeL
    return [nodeL - vector, nodeR + vector].filter { $0.isInRange(width: width, height: height) }
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    let (dict, width, height) = try Self.parseInput(input: data)
    var antiNodes: Set<Cord2D> = []
    for nodes in dict.values {
      let nodePairs = nodes.formPairs()
      for (nodeL, nodeR) in nodePairs {
        antiNodes.formUnion(self.antiNodes(nodeL: nodeL, nodeR: nodeR, height: height, width: width))
      }
    }
    return antiNodes.count
  }
  
  func resonantAntiNodes(nodeL: Cord2D, nodeR: Cord2D, height: Int, width: Int) -> [Cord2D] {
    let vector = nodeR - nodeL
    var antiNodes: [Cord2D] = []
    var currentNode: Cord2D = nodeL
    while currentNode.isInRange(width: width, height: height) {
      antiNodes.append(currentNode)
      currentNode = currentNode - vector
    }
    currentNode = nodeR
    while currentNode.isInRange(width: width, height: height) {
      antiNodes.append(currentNode)
      currentNode = currentNode + vector
    }
    return antiNodes
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part2() async throws -> Int {
    let (dict, width, height) = try Self.parseInput(input: data)
    var antiNodes: Set<Cord2D> = []
    for nodes in dict.values {
      let nodePairs = nodes.formPairs()
      for (nodeL, nodeR) in nodePairs {
        antiNodes.formUnion(self.resonantAntiNodes(nodeL: nodeL, nodeR: nodeR, height: height, width: width))
      }
    }
    return antiNodes.count
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day08 {}

struct Cord2D : Hashable, Sendable, Equatable {
  let x: Int
  let y: Int
  
  init(_ x: Int, _ y: Int) {
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

extension Array {
  func formPairs() -> [(Element, Element)] {
    var result: [(Element, Element)] = []
    var remainingElements = self.dropFirst(0)
    while remainingElements.count > 1 {
      let head = remainingElements.removeFirst()
      result = result + remainingElements.map { (head, $0) }
    }
    return result
  }
}
