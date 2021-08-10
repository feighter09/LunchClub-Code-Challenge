//
//  ContactListCoordinator.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import UIKit

protocol ContactListCoordinatorType: AnyObject {
  func start() -> UIViewController
  func showDetails(for contact: Contact)
}

class ContactListCoordinator: ContactListCoordinatorType {
  private var navigationController: UINavigationController?
}

// MARK: - Interface
extension ContactListCoordinator {
  func start() -> UIViewController {
    let viewModel = ContactsListViewModel(coordinator: self)
    let viewController = ContactsListViewController(viewModel: viewModel)
    let navigationController = UINavigationController(rootViewController: viewController)
    self.navigationController = navigationController
    return navigationController
  }

  func showDetails(for contact: Contact) {
    let viewModel = ContactDetailsViewModel(contact: contact)
    let detailsVC = ContactDetailsViewController(viewModel: viewModel)
    navigationController?.pushViewController(detailsVC, animated: true)
  }
}
