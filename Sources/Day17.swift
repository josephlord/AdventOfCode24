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
    var reverseComputer = ReverseComputer(computer: computer)
    try reverseComputer.run()
    return reverseComputer.registerA.description
  }
  
  struct ReverseComputer {
    var registerA: Int = 0
    var registerB: Int = 0
    var registerC: Int = 0
    var instructionPointer: Int
//    var output: [UInt8] = []
    var program: [UInt8] = []
    var expectedOutput: [UInt8] = []
    
    init(computer: Computer) {
      registerA = 0
      registerB = 0
      registerC = 0
      instructionPointer = computer.program.count - 2
      program = computer.program
      expectedOutput = .init(program.reversed())
    }
    
    mutating func run() throws {
      while try !performPrevious() {}
    }
    
    mutating func performPrevious() throws -> Bool {
      switch program[instructionPointer] {
      case 0:
        try adv()
      case 1:
        bxl()
      case 2:
        bst()
      case 3:
        if expectedOutput.isEmpty {
          return true
        }
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
      instructionPointer -= 2
      if instructionPointer < 0 {
        instructionPointer = program.count - 2
      }
      return false
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
      registerA = registerA * (1 << comboOperand)
    }
    
    mutating func bxl() {
      registerB = literalOperand ^ registerB
    }
    
    mutating func bst() {
      registerB = comboOperand & 7
    }
    
    mutating func jnz() {
      
    }
    
    mutating func bxc() {
      registerB = registerB ^ registerC
    }
    
    mutating func out() throws {
      let result = expectedOutput.removeLast()
      let operand = program[instructionPointer + 1]
      switch operand {
      case 0...3:
        precondition(operand == result)
      case 4:
        registerA = (registerA & ~7) | Int(result)
      case 5:
        registerB = (registerB & ~7) | Int(result)
      case 6:
        registerC = (registerC & ~7) | Int(result)
      default: preconditionFailure()
      }
    }
    
    mutating func bdv() throws {
      registerA = registerB * (1 << comboOperand)
    }
    
    mutating func cdv() throws {
      registerA = registerC * (1 << comboOperand)
    }
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day17 {}
