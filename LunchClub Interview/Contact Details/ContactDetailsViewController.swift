//
//  ContactDetailsViewController.swift
//  LunchClub Interview
//
//  Created by Austin Feight on 8/10/21.
//

import UIKit

class ContactDetailsViewController: UIViewController {
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var phoneNumberLabel: UILabel!
  @IBOutlet weak var notesLabel: UILabel!

  private let viewModel: ContactDetailsViewModelType
  init(viewModel: ContactDetailsViewModelType) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - View Life Cycle
extension ContactDetailsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    nameLabel.text = viewModel.name
    phoneNumberLabel.text = viewModel.phoneNumber
    notesLabel.text = viewModel.notes
  }
}
