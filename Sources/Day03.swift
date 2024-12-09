import Foundation
import RegexBuilder

struct Day03: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 3
  let puzzleName: String = "--- Day 3: Placeholder! ---"
  let multiples: [(Int,Int)]
  
  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  init(data: String) {
    self.data = data
    let mulRegex = Regex {
      "mul("
      TryCapture {
          OneOrMore {
            .digit
          }
      } transform: { Int($0) }
      ","
      TryCapture {
        OneOrMore {
          .digit
        }
      } transform: { Int($0) }
      ")"
    }
    multiples = data.matches(of: mulRegex).map { ($0.output.1, $0.output.2) }

  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    multiples.map { $0.0 * $0.1 }.reduce(0, +)
  }
  
  func part2() async throws -> Int {
    var part2Result = 0
    let mulRegex = Regex {
      "mul("
      TryCapture {
        OneOrMore {
          .digit
        }
      } transform: { Int($0) }
      ","
      TryCapture {
        OneOrMore {
          .digit
        }
      } transform: { Int($0) }
      ")"
    }
    let dontRegex = Regex {
      "don't()"
    }
    let doRegex = Regex {
      "do()"
    }
    var currentIndex = data.startIndex
    let endIndex = data.endIndex
    while currentIndex < endIndex {
      let nextSectionEnd = try dontRegex.firstMatch(in: data[currentIndex...])?.endIndex ?? endIndex
      part2Result += data[currentIndex..<nextSectionEnd].matches(of: mulRegex).map { $0.output.1 * $0.output.2 }.reduce(0, +)
      currentIndex = try doRegex.firstMatch(in: data[nextSectionEnd..<endIndex])?.range.upperBound ?? endIndex
    }
    return part2Result
  }
  
//  func part2() async throws -> Int {
//    var part2Result = 0
//    let mulRegex = Regex {
//      "mul("
//      TryCapture {
//          OneOrMore {
//            .digit
//          }
//      } transform: { Int($0) }
//      ","
//      TryCapture {
//        OneOrMore {
//          .digit
//        }
//      } transform: { Int($0) }
//      ")"
//    }
//    let dontRegex = Regex {
//      "don't()"
//    }
//    let doRegex = Regex {
//      "do()"
//    }
//    let doDontRegex = Regex {
//      "do()"
//      Capture {
//        OneOrMore {
//          .any
//        }
//      }
//      "don't()"
//    }
//    let firstDont = try! dontRegex.firstMatch(in: data)!
//    part2Result = data.prefix(upTo: firstDont.startIndex).matches(of: mulRegex).map { $0.output.1 * $0.output.2 }.reduce(0, +)
//    let remainingInput = data[firstDont.endIndex..<data.endIndex]
//    let doDontMatches = remainingInput.matches(of: doDontRegex)
//    part2Result += doDontMatches
//      .map { $0.output.1.matches(of: mulRegex)
//          .map { $0.output.1 * $0.output.2 }
//          .reduce(0, +) }
//      .reduce(0, +)
//    let lastDoSearchStart = doDontMatches.last?.range.upperBound ?? firstDont.endIndex
//    let afterLastDoDont = data[lastDoSearchStart..<data.endIndex]
//    if let finalDo = try! doRegex.firstMatch(in: afterLastDoDont) {
//      part2Result += data[finalDo.endIndex..<data.endIndex].matches(of: mulRegex).map { $0.output.1 * $0.output.2 }.reduce(0, +)
//    }
//    
//    return part2Result
//  }
  
//  func parse(_ input: String) -> Int {
//    var status = RunningResult.ParseState.enabled
//    var total = 0
//    for char in input {
//      switch (char, status) {
//      case ("m", .enabled)
//      }
//    }
//  }
//  
//  struct RunningResult {
//    var total = 0
//    var state: ParseState = .enabled
//    enum ParseState {
//      case enabled, disabled, m, mu, mul, mulB, d, `do`, doB, don, donA, donAt, donAtB
//      case mulOne(val: Int)
//      case mulTwo(val: Int)
//    }
//  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day03 {}
