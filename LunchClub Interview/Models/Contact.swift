//
//  Contact.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import Foundation

struct Contact: Codable {
  let id: String?
  let first: String
  let last: String
  let number: String
  let notes: String
  let base64EncodedImage: String?
}
