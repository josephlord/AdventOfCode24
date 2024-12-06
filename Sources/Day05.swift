import Foundation
import RegexBuilder

struct Day05: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 5
  let puzzleName: String = "--- Day 5: Print Queue! ---"
  let updateLists: [[Int]]
  let followsDict: [Int: Set<Int>]

  init(data: String) {
    self.data = data
    let (pairs, updateLists) = Self.parseInput(data: data)
    self.updateLists = updateLists
    var followsDict: [Int: Set<Int>] = [:]
    for (before, after) in pairs {
      followsDict[after, default: []].insert(before)
    }
    self.followsDict = followsDict
  }
  
  static func parseInput(data: String) -> ([(Int,Int)],[[Int]]) {
    let pairsRegex = Regex {
      TryCapture {
        OneOrMore(.digit)
      } transform: { Int($0) }
      "|"
      TryCapture {
        OneOrMore(.digit)
      } transform: { Int($0) }
    }
    var updateLists: [[Int]] = []
    var pairList: [(Int, Int)] = []
    for line in data.lines {
      if line.isEmpty { continue }
      if let pair = try! pairsRegex.firstMatch(in: line) {
        pairList.append((pair.1, pair.2))
      } else {
        updateLists.append(line.split(separator: ",").compactMap { Int($0) })
      }
    }
    return (pairList, updateLists)
  }

  func middleValue(_ list: [Int]) -> Int {
    list[list.count / 2]
  }
  
  
  
  func isValidList(_ list: [Int].SubSequence) -> Bool {
    let tail = list.dropFirst()
    if let mustPrecede = followsDict[list.first!],
       !mustPrecede.isDisjoint(with: tail) {
      return false
    }
    if list.count > 1 {
      return isValidList(list.dropFirst())
    }
    return true
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    var total = 0
    for list in updateLists {
      if isValidList(list.dropFirst(0)) {
        total += middleValue(list)
      }
    }
    return total
  }
  
  // Everything upto the index should be ordered already
  func reorder(index: Int, list: [Int]) -> [Int] {
    let indexVal = list[index]
    guard let mustFollows = followsDict[indexVal] else { return list }
    for i in (index.advanced(by: 1)..<list.endIndex).reversed() {
      if mustFollows.contains(list[i]) {
        var reordered = list
        for j in index...(i-1) {
          reordered[j] = reordered[j+1]
        }
        reordered[i] = indexVal
        return reorder(index: index, list: reordered)
      }
    }
    return list
  }
  
  func reorder(_ list: [Int]) -> [Int] {
    var reordered = list
    for index in reordered.indices.dropLast() {
      if isValidList(reordered.dropFirst(0)) {
        return reordered
      }
      reordered = reorder(index: index, list: reordered)
    }
    return reordered
  }
  
  func part2() async throws -> Int {
    var total = 0
    for list in updateLists {
      if !isValidList(list.dropFirst(0)) {
        let reordered = reorder(list)
        total += middleValue(reordered)
      }
    }
    return total
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day05 {}
