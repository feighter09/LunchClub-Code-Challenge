//
//  ContactsListViewModel.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import Bond
import Foundation
import ReactiveKit

protocol ContactsListViewModelType: AnyObject {
  var contacts: Observable<[Contact]> { get }
  var filter: Observable<String> { get }

  func showDetails(for index: Int)
  func delete(row: Int)
}

class ContactsListViewModel: ContactsListViewModelType {
  let contacts = Observable<[Contact]>([])
  let filter = Observable<String>("")

  private let allContacts = Observable<[Contact]>([])

  private let contactService: ContactServiceType
  private weak var coordinator: ContactListCoordinatorType?

  init(
    contactService: ContactServiceType = ContactService(),
    coordinator: ContactListCoordinatorType = ContactListCoordinator()
  ) {
    self.contactService = contactService
    self.coordinator = coordinator

    contactService.uploadLocalContacts { [weak self] in
      self?.fetchContacts()
    }
    setupFilter()
  }
}

// MARK: - Interface
extension ContactsListViewModel {
  func showDetails(for index: Int) {
    guard let contact = allContacts.value[safe: index]
      else { return } // Fixup: handle error

    coordinator?.showDetails(for: contact)
  }

  func delete(row: Int) {
    guard let contact = allContacts.value[safe: row]
      else { return } // Fixup: handle error

    contactService.delete(contact) { [weak self] in self?.fetchContacts() }
  }
}


// MARK: - Helpers
private extension ContactsListViewModel {
  func fetchContacts() {
    contactService.fetchContacts { [allContacts] fetchedContacts in
      allContacts.value = fetchedContacts
    }
  }

  func setupFilter() {
    combineLatest(allContacts, filter)
      .map { (contacts: [Contact], filter: String) -> [Contact] in
        guard !filter.isEmpty
          else { return contacts }

        return contacts.filter({ $0.matches(filter) })
      }
      .bind(to: contacts)
  }
}

private extension Contact {
  func matches(_ searchText: String) -> Bool {
    let searchText = searchText.removingSpecialCharacters.lowercased()
    let name = "\(first) \(last) \(number)".removingSpecialCharacters.lowercased()
    return name.contains(searchText)
  }
}

extension String {
  var removingSpecialCharacters: String {
    let characterSet = CharacterSet.alphanumerics
    return filter({ characterSet.contains(character: $0) })
  }
}

extension CharacterSet {
  func contains(character: Character) -> Bool {
    return character.unicodeScalars.allSatisfy(contains(_:))
  }
}
