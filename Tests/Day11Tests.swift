  import Testing

  @testable import AdventOfCode

  @Suite("Day11 Tests")
  struct Day11Tests {
  @Suite("Parser Tests")
    
    struct IntExtensionsTests {
      @Test("Test split")
      func testDigitSplitIfEven() {
        #expect(7234.digitSplitIfEven == [34, 72])
      }
    }
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
      let day = Day11(data: testInput)

      @Test("Part1 example")
      func testPart1() async throws {
          let result = try await day.part1()
          #expect(result == 55312)
      }

      @Test("Part2 example")
      func testPart2() async throws {
        await withKnownIssue {
          let result = try await day.part2()
          #expect(result == 10)
        }
      }
    }
  }
}

private let testInput =
  """
  125 17
  """
