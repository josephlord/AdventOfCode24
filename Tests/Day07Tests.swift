  import Testing

  @testable import AdventOfCode

  @Suite("Day07 Tests")
  struct Day07Tests {
  @Suite("Parser Tests")
  struct ParserTests {
    @Test("Test parser implementation")
    func parseInput() {
      let result = Day07.parseInput(testInput)
      #expect(result.count == 9)
      #expect(result[0] == (190, [10,19]))
      #expect(result[8] == (292, [11,6,16,20]))
    }
  }

  @Suite("Tests on sample inputs")
  struct SolutionsTests {
    @Suite("Tests on sample inputs")
    struct SolutionsTests {
      let day = Day07(data: testInput)

      @Test("Part1 example")
      func testPart1() async throws {
          let result = try await day.part1()
          #expect(result == 3749)
      }

      @Test("Part2 example")
      func testPart2() async throws {

          let result = try await day.part2()
          #expect(result == 11387)
        }
    }
  }
}

private let testInput =
  """
  190: 10 19
  3267: 81 40 27
  83: 17 5
  156: 15 6
  7290: 6 8 6 15
  161011: 16 10 13
  192: 17 8 14
  21037: 9 7 18 13
  292: 11 6 16 20
  """
