  import Testing

  @testable import AdventOfCode

  @Suite("Day10 Tests")
  struct Day10Tests {
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
      let day = Day10(data: testInput)

      @Test("Part1 example")
      func testPart1() async throws {
        let result = try await day.part1()
        #expect(result == 36)
      }

      @Test("Part2 example")
      func testPart2() async throws {
          let result = try await day.part2()
          #expect(result == 81)
      }
    }
  }
}

private let testInputMini =
  """
  0123
  1234
  8765
  9876
  """

private let testInput = """
  89010123
  78121874
  87430965
  96549874
  45678903
  32019012
  01329801
  10456732
  """
