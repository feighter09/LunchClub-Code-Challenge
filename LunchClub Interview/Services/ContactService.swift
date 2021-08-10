//
//  ContactService.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import Contacts
import Foundation

protocol ContactServiceType {
  func uploadLocalContacts(callback: @escaping () -> Void)
  func fetchContacts(callback: @escaping ([Contact]) -> Void)
  func delete(_ contact: Contact, callback: @escaping () -> Void)
}

class ContactService: ContactServiceType {
  fileprivate enum Constants {
    static let auth = "austin5"
  }

  private let urlSession: URLSession
  private let contactStore: CNContactStore
  private let userDefaults: UserDefaults

  init(
    urlSession: URLSession = URLSession(configuration: .default),
    contactStore: CNContactStore = CNContactStore(),
    userDefaults: UserDefaults = .standard
  ) {
    self.urlSession = urlSession
    self.contactStore = contactStore
    self.userDefaults = userDefaults
  }
}

// MARK: - Interface
extension ContactService {
  func uploadLocalContacts(callback: @escaping () -> Void) {
    // Fixup: Promise would be nicer
    requestPermissionIfNeeded {
      self.fetchLocalContacts { contacts in
        self.upload(contacts) {
          callback()
        }
      }
    }
  }

  func fetchContacts(callback: @escaping ([Contact]) -> Void) {
    // Fixup: Promise would be nicer
    guard let request = URLRequest.fetchContacts
      else { return } // Fixup: handle error

    urlSession.dataTask(with: request) { data, response, error in
      guard let data = data else { return }
      guard let response = try? JSONDecoder().decode(APIResponse.self, from: data) else { return }
      callback(response.contacts)
    }.resume()
  }

  func delete(_ contact: Contact, callback: @escaping () -> Void) {
    // Fixup: Promise would be nicer
    guard let request = URLRequest.delete(contact)
      else { return } // Fixup: handle error

    urlSession.dataTask(with: request) { data, response, error in
      callback()
    }.resume()
  }
}

// MARK: - Helpers
private extension ContactService {
  func requestPermissionIfNeeded(then callback: @escaping () -> Void) {
    guard CNContactStore.authorizationStatus(for: .contacts) != .authorized
    else { return callback() }

    contactStore.requestAccess(for: .contacts) { granted, error in
      if granted {
        callback()
      }
    }
  }

  func fetchLocalContacts(callback: @escaping ([Contact]) -> Void) {
    DispatchQueue.global(qos: .background).async { [contactStore] in
      let contacts: [Contact]
      do {
        contacts = try contactStore.getAllContacts()
      } catch let error {
        NSLog("Failed to enumerate contact: \(error)")
        return
      }

      callback(contacts)
    }
  }

  func upload(_ contacts: [Contact], callback: @escaping () -> Void) {
    let uploads = contacts.compactMap(URLRequest.upload(_:))

    var done = 0
    uploads.forEach { upload in
      urlSession.dataTask(with: upload) { data, response, error in
        // Fixup: do something with errors here
        done += 1
        if done == uploads.count {
          // holy shit we should have promises
          callback()
        }
      }.resume()
    }
  }

  struct APIResponse: Codable {
    let contacts: [Contact]
  }
}

private extension CNContactStore {
  func getAllContacts() throws -> [Contact] {
    let keys = [
      CNContactGivenNameKey,
      CNContactFamilyNameKey,
      CNContactPhoneNumbersKey,
      CNContactNoteKey,
      CNContactThumbnailImageDataKey,
    ]
    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])

    var contacts: [Contact] = []
    try enumerateContacts(with: request) { contact, _ in
      let fetchedContact = Contact(
        id: nil,
        first: contact.givenName,
        last: contact.familyName,
        number: contact.phoneNumbers.first?.value.stringValue ?? "",
        notes: contact.note,
        base64EncodedImage: contact.thumbnailImageData?.base64EncodedString()
      )
      contacts.append(fetchedContact)
    }

    return contacts
  }
}

private extension URLRequest {
  static var fetchContacts: URLRequest? {
    guard let url = URL(string: "https://address-book-lunchclub.herokuapp.com/contacts")
    else {
      // Fixup: report error to sentry
      return nil
    }

    var request = URLRequest(url: url)
    request.addValue(ContactService.Constants.auth, forHTTPHeaderField: "Authorization")
    return request
  }

  static func delete(_ contact: Contact) -> URLRequest? {
    guard let id = contact.id, let url = URL(string: "https://address-book-lunchclub.herokuapp.com/contacts/\(id)")
    else {
      // Fixup: report error to sentry
      return nil
    }

    var request = URLRequest(url: url)
    request.addValue(ContactService.Constants.auth, forHTTPHeaderField: "Authorization")
    request.httpMethod = "DELETE"
    return request
  }

  struct UploadPayload: Codable {
    let contact: Contact
  }

  static func upload(_ contact: Contact) -> URLRequest? {
    guard let url = URL(string: "https://address-book-lunchclub.herokuapp.com/contacts")
    else {
      // Fixup: report error to sentry
      return nil
    }

    var request = URLRequest(url: url)
    request.addValue(ContactService.Constants.auth, forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = try? JSONEncoder().encode(UploadPayload(contact: contact))
    return request
  }
}
