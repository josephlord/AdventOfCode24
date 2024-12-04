//
//  StringUtils.swift
//  AdventOfCode
//
//  Created by Joseph Lord on 01/12/2024.
//

extension String {
  var lines:[Substring] {
    self.split(whereSeparator: \.isNewline)
  }
}
