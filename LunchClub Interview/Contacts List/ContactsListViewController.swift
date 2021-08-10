//
//  ContactsListViewController.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import UIKit

class ContactsListViewController: UIViewController {
  fileprivate enum Constants {
    static let reuseIdentifier = "cell"
  }

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet private(set) weak var tableView: UITableView!

  private let viewModel: ContactsListViewModelType
  init(viewModel: ContactsListViewModelType = ContactsListViewModel()) {
    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - View Life Cycle
extension ContactsListViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    setupTableView()
    setupSearchBar()
    setupAddContact()
  }
}

// MARK: - Helpers
private extension ContactsListViewController {
  func setupTableView() {
    tableView.register(ContactsListCell.nib, forCellReuseIdentifier: Constants.reuseIdentifier)
    viewModel.contacts.bind(to: tableView, createCell: createCell)
    tableView.delegate = self
  }

  func setupSearchBar() {
    searchBar.delegate = self
  }

  func setupAddContact() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addContact)
    )
  }

  @objc func addContact() {
    let alertController = UIAlertController(title: "Add new contact", message: nil, preferredStyle: .alert)
    alertController.addTextField { textField in textField.placeholder = "First name" }
    alertController.addTextField { textField in textField.placeholder = "Last name" }
    alertController.addTextField { textField in textField.placeholder = "Phone number" }
    alertController.addTextField { textField in textField.placeholder = "Notes" }

    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
      // Add the thing
    }))
    alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))

    present(alertController, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDelegate
extension ContactsListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.showDetails(for: indexPath.row)
    tableView.deselectRow(at: indexPath, animated: true)
  }

  func tableView(
    _ tableView: UITableView,
    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    let deleteRow = UIContextualAction(style: .destructive, title: "Delete") { [viewModel] _, _, tapped in
      viewModel.delete(row: indexPath.row)
    }

    return UISwipeActionsConfiguration(actions: [deleteRow])
  }
}

private func createCell(dataSource: [Contact], indexPath: IndexPath, tableView: UITableView) -> UITableViewCell {
  let cell = tableView.dequeueReusableCell(
    withIdentifier: ContactsListViewController.Constants.reuseIdentifier,
    for: indexPath
  )
  guard let viewModel = dataSource[safe: indexPath.row]
    else {
      // report some error to service
      return cell
    }

  cell.textLabel?.text = "\(viewModel.first) \(viewModel.last)"
  cell.detailTextLabel?.text = viewModel.number
  let imageData: Data? = viewModel.base64EncodedImage.flatMap({ Data(base64Encoded: $0) })
  let image = imageData.flatMap(UIImage.init(data:))
  cell.imageView?.image = image

  return cell
}

// MARK: - UISearchBarDelegate
extension ContactsListViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.filter.value = searchText
  }
}
