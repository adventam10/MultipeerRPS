//
//  EditAccountNameTableViewController.swift
//  MultipeerRPS
//
//  Created by makoto on 2021/02/22.
//

import UIKit

final class EditAccountNameTableViewController: UITableViewController {

    @IBOutlet private weak var accountTextField: UITextField!

    var presentationModel: EditAccountNamePresentationModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        accountTextField.resignFirstResponder()
        presentationModel.updateAccountName(accountTextField.text)
    }

    private func setupViews() {
        title = presentationModel.screenTitle
        accountTextField.delegate = self
        accountTextField.placeholder = UIDevice.current.name
        accountTextField.text = presentationModel.accountName
        accountTextField.becomeFirstResponder()
    }
}

extension EditAccountNameTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        accountTextField.resignFirstResponder()
        return true
    }
}
