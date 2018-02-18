//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

enum CredentialsType {
    case firstname
    case secondname
}

class EditCredentialsViewController: BaseViewController {

    var credentialsTitle: String!
    var valueToChange: String!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.credentialsTitle
        self.textField.text = self.valueToChange
        self.updateSaveButtonState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
    // MARK: - Private
    
    private func updateSaveButtonState() {
        saveButton.isEnabled = self.isNewValueValid()
    }
    
    private func isNewValueValid() -> Bool {
        let newValue = textField.text
        return newValue != nil && newValue != "" && newValue != valueToChange
    }
    
    // MARK: - IBActions
    
    @IBAction private func onTextFieldTextChanged(_ sender: UITextField) {
        self.updateSaveButtonState()
    }
    
    @IBAction private func onBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onSavePressed(_ sender: UIButton) {
        self.valueToChange = self.textField.text!
        self.runSegue(Constants.segueIDs.unwindEditCredentialsToProfile)
    }
    
}
