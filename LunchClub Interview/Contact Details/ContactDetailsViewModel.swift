//
//  ContactDetailsViewModel.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import Foundation

protocol ContactDetailsViewModelType {
  var name: String { get }
  var phoneNumber: String { get }
  var notes: String { get }
}

class ContactDetailsViewModel: ContactDetailsViewModelType {
  let name: String
  let phoneNumber: String
  let notes: String

  init(contact: Contact) {
    name = "\(contact.first) \(contact.last)"
    phoneNumber = "Phone number: \(contact.number)"
    notes = "Notes: \(contact.notes)"
  }
}
