  import Testing

  @testable import AdventOfCode

  @Suite("Day05 Tests")
  struct Day05Tests {
  @Suite("Parser Tests")
  struct ParserTests {
    @Test("Test parser implementation")
    func parseInput() {
      let (pairs, updateList) = Day05.parseInput(data: testInput)
      #expect(updateList.count == 6)
      #expect(pairs.count == 21)
      #expect(pairs.first ?? (0,0) == (47,53))
      #expect(pairs.last ?? (0,0) == (53,13))
      #expect(updateList.first == [75,47,61,53,29])
      #expect(updateList.last == [97,13,75,29,47])
    }
  }

  @Suite("Tests on sample inputs")
  struct SolutionsTests {
    @Suite("Tests on sample inputs")
    struct SolutionsTests {
      let day = Day05(data: testInput)

      @Test("Part1 example")
      func testPart1() async throws {
          let result = try await day.part1()
          #expect(result == 143)
      }

      @Test("Part2 example")
      func testPart2() async throws {
          let result = try await day.part2()
          #expect(result == 123)
      }
    }
  }
}

private let testInput =
  """
  47|53
  97|13
  97|61
  97|47
  75|29
  61|13
  75|53
  29|13
  97|29
  53|29
  61|53
  97|53
  61|29
  47|13
  75|47
  97|75
  47|61
  75|61
  47|29
  75|13
  53|13

  75,47,61,53,29
  97,61,53,29,13
  75,29,13
  75,97,47,61,53
  61,13,29
  97,13,75,29,47
  """
// 97,75,47,13, 29
