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
  
  struct FreeSpace {
    var index: Int
    var size: UInt8
  }
  
  struct File {
    var index: Int
    var id: Int16
    var size: UInt8
  }
  
  func scoreFile(file: File, atIndex: Int) -> Int {
    var total = 0
    var index = atIndex
    for _ in 0..<file.size {
      total += index * Int(file.id)
      index += 1
    }
    return total
  }
  
  func firstIndexOfFreeSpace(freeSpaces:[FreeSpace], size: UInt8, beforeIndex: Int) -> Int? {
    for (i, freeSpace) in freeSpaces.lazy.enumerated() {
      if freeSpace.index >= beforeIndex {
        return nil
      }
      if freeSpace.size >= size {
        return i
      }
    }
    return nil
  }
  
  func part2() async throws -> Int {
    // Array of indexes and sizes of free space
    var freeLists: [FreeSpace] = []
    var files: [File] = []
    var nextIsFile = true
    var nextFileId: Int16 = 0
    var currentPositionIndex = 0
    for val in diskMap {
      if nextIsFile {
        files.append(File(index: currentPositionIndex, id: nextFileId, size: val))
        nextFileId += 1
        
      } else if val != 0 {
        freeLists.append(FreeSpace(index: currentPositionIndex, size: val))
      }
      currentPositionIndex += Int(val)
      nextIsFile.toggle()
    }
    var runningTotal = 0
    for file in files.reversed() {
      if let i = firstIndexOfFreeSpace(freeSpaces: freeLists, size: file.size, beforeIndex: file.index) {
        runningTotal += scoreFile(file: file, atIndex: freeLists[i].index)
        if freeLists[i].size > file.size {
          freeLists[i].index += Int(file.size)
          freeLists[i].size -= file.size
        } else {
          freeLists.remove(at: i)
        }
      } else {
        runningTotal += scoreFile(file: file, atIndex: file.index)
      }
    }
    return runningTotal
  }
}

// Add any extra code and types in here to separate it from the required behaviour
extension Day09 {}
