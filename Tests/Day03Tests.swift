  import Testing

  @testable import AdventOfCode

  @Suite("Day03 Tests")
  struct Day03Tests {
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
      

      @Test("Part1 example")
      func testPart1() async throws {
        let day = Day03(data: testInput)
          let result = try await day.part1()
          #expect(result == 161)
      }

      @Test("Part2 example")
      func testPart2() async throws {
        let day = Day03(data: testInput2)
          let result = try await day.part2()
          #expect(result == 48)
      }
    }
  }
}

private let testInput =
  """
  xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
  """
private let testInput2 =
"""
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
"""
