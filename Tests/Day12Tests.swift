  import Testing

  @testable import AdventOfCode

  @Suite("Day12 Tests")
  struct Day12Tests {
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
      let day = Day12(data: testInput)

      @Test("Part1 example")
      func testPart1() async throws {
          let result = try await day.part1()
          #expect(result == 1930)
      }

      @Test("Part2 example")
      func testPart2() async throws {
          let result = try await day.part2()
          #expect(result == 1206)
      }
    }
    
    @Suite("Tests on sample inputs")
    struct MiniSolutionsTests {
      let day = Day12(data: miniTestInput)

      @Test("Part1 example")
      func testPart1() async throws {
          let result = try await day.part1()
          #expect(result == 140)
      }

      @Test("Part2 example")
      func testPart2() async throws {
          let result = try await day.part2()
          #expect(result == 80)
      }
    }
  }
}
private let miniTestInput =
  """
  AAAA
  BBCD
  BBCC
  EEEC
  """

private let testInput =
  """
  RRRRIICCFF
  RRRRIICCCF
  VVRRRCCFFF
  VVRCCCJFFF
  VVVVCJJCFE
  VVIVCCJJEE
  VVIIICJJEE
  MIIIIIJJEE
  MIIISIJEEE
  MMMISSJEEE
  """
