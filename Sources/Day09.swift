import Foundation

struct Day09: AdventDay, Sendable {
  // Save your data in a corresponding text file in the `Data` directory.
  let day = 9
  let puzzleName: String = "--- Day 9: Disk Fragmenter! ---"
  let diskMap: [UInt8]
  
  init(rawData: [UInt8]) {
    let zeroAsciiValue = UInt8(ascii: "0")
    diskMap = rawData.compactMap { $0 < zeroAsciiValue ? nil : $0 - zeroAsciiValue }
//    let dayString = String(format: "%02d", 9)
//    let dataFilename = "day\(dayString)"
//    let dataURL = Bundle.module.url(
//      forResource: dataFilename,
//      withExtension: "txt",
//      subdirectory: "Data"
//    )!
//    let zeroAsciiValue = UInt8(ascii: "0")
//    print(try! Data(contentsOf: dataURL).description)
//    diskMap = try! Data(contentsOf: dataURL).map { $0 - zeroAsciiValue }
  }
  
  init(data: String) {
    preconditionFailure()
  }

  // Replace this with your solution for the first part of the day's challenge.
  func part1() async throws -> Int {
    let count = diskMap.count
    var currentEndFileId = (count / 2) + 1
    var remainingEndFileLength = 0
    var currentStartFileId = 0
    var currentPositionIndex = 0
    var runningtotal = 0
    var forwardIndex = diskMap.startIndex
    var backwardIndex = diskMap.endIndex + 1
    while forwardIndex < backwardIndex {
      let fileLength = diskMap[forwardIndex]
      for _ in 0..<fileLength {
        runningtotal += currentPositionIndex * currentStartFileId
        currentPositionIndex += 1
      }
      currentStartFileId += 1
      forwardIndex += 1
      var emptySpaceLength = diskMap[forwardIndex]
      forwardIndex += 1
      while emptySpaceLength > 0 {
        if remainingEndFileLength == 0 {
          backwardIndex -= 2
          currentEndFileId -= 1
          remainingEndFileLength = Int(diskMap[backwardIndex])
          continue // In case the the file length is zero
        }
        runningtotal += currentEndFileId * currentPositionIndex
        remainingEndFileLength -= 1
        currentPositionIndex += 1
        emptySpaceLength -= 1
      }
    }
    for _ in 0..<remainingEndFileLength {
      runningtotal += currentEndFileId * currentPositionIndex
      currentPositionIndex += 1
    }
    return runningtotal
  }
  
  func part2() async throws -> Int {
    0
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day09 {}
