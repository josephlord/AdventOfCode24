import Foundation
import RegexBuilder

struct Day01: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 1
  let puzzleName: String = "--- Day 1: Historian Hysteria ---"
  let list1: [Int]
  let list2: [Int]
  
  let digitCountsLeft: [Int: Int]
  let digitCountsRight: [Int: Int]
  

  init(data: String) {
    let lineRegex = Regex {
      Capture {
        OneOrMore(.digit)
      } transform: { Int($0)! }
      OneOrMore {
        " "
      }
      Capture {
        OneOrMore(.digit)
      } transform: { Int($0)! }
    }
    self.data = data
    var list1tmp: [Int] = []
    var list2tmp: [Int] = []
    for line in data.lines {
      let match = try! lineRegex.wholeMatch(in: line)
      list1tmp.append(match!.output.1)
      list2tmp.append(match!.output.2)
    }
    list1 = list1tmp.sorted()
    list2 = list2tmp.sorted()
    
    var digitCountsLeftT: [Int: Int] = [:]
    var digitCountsRightT: [Int: Int] = [:]
    
    for i in list1 {
      digitCountsLeftT[i] = 1 + (digitCountsLeftT[i] ?? 0)
    }
    for i in list2 {
      digitCountsRightT[i] = 1 + (digitCountsRightT[i] ?? 0)
    }
    digitCountsLeft = digitCountsLeftT
    digitCountsRight = digitCountsRightT
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    zip(list1, list2).map { diff(lhs: $0.0, rhs: $0.1) }.reduce(0, +)
  }
  
  func part2() async throws -> Int {
    digitCountsLeft.reduce(0) {
      $0 + ($1.key * $1.value) * (digitCountsRight[$1.key] ?? 0)
    }
  }
}

func diff(lhs: Int, rhs: Int) -> Int {
  lhs >= rhs ? lhs - rhs : rhs - lhs
}


// Add any extra code and types in here to separate it from the required behaviour
extension Day01 {}
