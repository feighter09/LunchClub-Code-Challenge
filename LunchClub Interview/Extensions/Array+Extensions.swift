//
//  Array+Extensions.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import Foundation

extension Array {
  subscript(safe index: Index) -> Element? {
    guard 0 <= index && index < count
      else { return nil }

    return self[index]
  }
}

