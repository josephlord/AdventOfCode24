  import Testing

  @testable import AdventOfCode

  @Suite("Day18 Tests")
  struct Day18Tests {
  @Suite("Parser Tests")
  struct ParserTests {
    @Test("Test parser implementation")
    func parseInput() {
      //
    }
  }

  @Suite("Tests on sample inputs")
  struct SolutionsTests {
    @Suite("Tests on sample inputs")
    struct SolutionsTests {
      let day = Day18(data: testInput)

      @Test("Part1 example")
      func testPart1() async throws {
//        let inputFirst12 = String(testInput.lines.prefix(12).joined(separator: "\n"))
        let result = try day.doPart1(input: testInput, gridSize: 7, addressCount: 12)
          #expect(result == 22)
      }

      @Test("Part2 example")
      func testPart2() async throws {
        let (resultCord, resultIndex) = try day.doPart2(gridsize: 7)
        #expect(resultCord == .init(6,1))
      }
    }
  }
}

private let testInput =
  """
  5,4
  4,2
  4,5
  3,0
  2,1
  6,3
  2,4
  1,5
  0,6
  3,3
  2,6
  5,1
  1,2
  5,5
  2,5
  6,5
  1,4
  0,4
  6,4
  1,1
  6,1
  1,0
  0,5
  1,6
  2,0
  """
