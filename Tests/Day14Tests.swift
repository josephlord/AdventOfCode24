  import Testing

  @testable import AdventOfCode

  @Suite("Day14 Tests")
  struct Day14Tests {
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
      let day = Day14(data: testInput)

      @Test("Part1 example")
      func testPart1() async throws {
        let result = day.doPart1(
          data: testInput,
          width: 11,
          height: 7,
          seconds: 100)
        #expect(result == 12)
      }

      @Test("Part2 example")
      func testPart2() async throws {
        let result = try day.doPart2(data: testInput, width: 11, height: 7)
      }
    }
  }
}

private let testInput =
  """
  p=0,4 v=3,-3
  p=6,3 v=-1,-3
  p=10,3 v=-1,2
  p=2,0 v=2,-1
  p=0,0 v=1,3
  p=3,0 v=-2,-2
  p=7,6 v=-1,-3
  p=3,0 v=-1,-2
  p=9,3 v=2,3
  p=7,3 v=-1,2
  p=2,4 v=2,-3
  p=9,5 v=-3,-3
  """
