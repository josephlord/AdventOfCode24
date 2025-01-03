import Foundation
import RegexBuilder

struct Day17: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let data: String
  let day = 17
  let puzzleName: String = "--- Day 17: Chronospatial Computer ---"

  init(data: String) {
    self.data = data
  }
  
  init(rawData: [UInt8]) {
    preconditionFailure()
  }
  
  struct Computer {
    var registerA: Int = 0
    var registerB: Int = 0
    var registerC: Int = 0
    var instructionPointer: Int = 0
    var output: [UInt8] = []
    var program: [UInt8] = []
    var expectedOutput: [UInt8]? = nil
    
    enum ComputerError : Error {
      case unexpectedOutput
    }
    
    mutating func run() throws {
      while instructionPointer < program.count {
        try peformNext()
      }
    }
    
    mutating func peformNext() throws {
      switch program[instructionPointer] {
      case 0:
        try adv()
      case 1:
        bxl()
      case 2:
        bst()
      case 3:
        jnz()
        return
      case 4:
        bxc()
      case 5:
        try out()
      case 6:
        try bdv()
      case 7:
        try cdv()
      default:
        preconditionFailure()
      }
      instructionPointer += 2
    }
    
    var comboOperand: Int {
      let operandVal = program[instructionPointer + 1]
      return switch operandVal {
      case 0...3:
        Int(operandVal)
      case 4:
        registerA
      case 5:
        registerB
      case 6:
        registerC
      default:
        preconditionFailure()
      }
    }
    
    var literalOperand: Int {
      Int(program[instructionPointer + 1])
    }
    
    mutating func adv() throws {
      registerA = registerA / (1 << comboOperand)
    }
    
    mutating func bxl() {
      registerB = literalOperand ^ registerB
    }
    
    mutating func bst() {
      registerB = comboOperand & 7
    }
    
    mutating func jnz() {
      guard registerA != 0 else {
        instructionPointer += 2
        return
      }
      instructionPointer = literalOperand
    }
    
    mutating func bxc() {
      registerB = registerB ^ registerC
    }
    
    mutating func out() throws {
      let outVal = UInt8(comboOperand % 8)
      if expectedOutput != nil {
        let nextExpected = expectedOutput!.removeLast()
        if nextExpected != outVal {
          throw ComputerError.unexpectedOutput
        }
      } else {
        output.append(outVal)
      }
    }
    
    mutating func bdv() throws {
      registerB = registerA / (1 << comboOperand)
    }
    
    mutating func cdv() throws {
      registerC = registerA / (1 << comboOperand)
    }
  }

  static func parseInput(_ input: String) throws -> Computer {
    let lines = input.lines
    var iter = lines.makeIterator()
    let registerLine = Regex {
      "Register "
      One(CharacterClass.anyOf("ABC"))
      ": "
      TryCapture {
        OneOrMore(.digit)
      } transform: { Int($0) }
    }
    
    var result = Computer()
    result.registerA = try registerLine.firstMatch(in: iter.next()!)!.output.1
    result.registerB = try registerLine.firstMatch(in: iter.next()!)!.output.1
    result.registerC = try registerLine.firstMatch(in: iter.next()!)!.output.1
    
    let progRegex = Regex {
      "Program: "
      Capture {
        OneOrMore {
          CharacterClass(
            .anyOf(","),
            .digit
          )
        }
      }
    }
    let progText = try progRegex.firstMatch(in: iter.next()!)!.output.1
    result.program = progText.split(separator: ",").map { UInt8($0)! }
    return result
  }
  
  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> String {
    var computer = try Self.parseInput(data)
    try computer.run()
    return computer.output.map { $0.description }.joined(separator: ",")
  }
  
  func part2() async throws -> String {
    let computer = try Self.parseInput(data)
    let targetOutput = computer.program
    var registerAInitialValue = 0
    var nextTargetLength: Int = 1
    while nextTargetLength <= targetOutput.count {
      registerAInitialValue <<= 3
      let reducedTarget = Array(targetOutput.suffix(nextTargetLength))
      while true {
        var computerCopy = computer
        computerCopy.registerA = registerAInitialValue
        try computerCopy.run()
        if computerCopy.output == reducedTarget {
          nextTargetLength += 1
          break
        }
        registerAInitialValue += 1
      }
    }
    
    return registerAInitialValue.description
  }

  
//  2 4 bst regB = regA AND 7
//  1 3 bxl regB = regB XOR 3
//  7 5 cdv regC = regA >> regB
//  0 3 adv regA = regA >> 3
//  1 5 bxl regB = regB XOR 5
//  4 4 bxc regB = regB XOR regC
//  5 5 out regB % 8
//  3 0 Goto start if reg A != 0

}

// Add any extra code and types in here to separate it from the required behaviour
extension Day17 {}
