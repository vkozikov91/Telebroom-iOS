//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import PromiseKit

class SearchViewController: BaseTableViewController {
    
    @IBOutlet private weak var searchTextField: UITextField!
    
    var selectedUser: RemoteUserViewModel?
    
    private var viewModel: SearchViewModel {
        return self.viewModels.first! as! SearchViewModel
    }
    
    
    // MARK: - Override Base
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if searchTextField.text == "" {
            searchTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.resignFirstResponder()
    }
    
    override func configureTableView() {
        super.configureTableView()
        self.tableView.rowHeight = 77.0
    }
    
    
    // MARK: - Override MVVM
    
    override func setViewModels() {
        self.viewModels = [router.vmFactory.getSearchViewModel()]
    }
    
    override func bindViewModels() {
        super.bindViewModels()
        self.viewModel.searchResults
            .asObservable()
            .bind(to: self.tableView.rx.items(
                cellIdentifier: SearchUserCell.reuseId,
                cellType: SearchUserCell.self)) { row, remoteUserVM, cell in
                    cell.viewModel = remoteUserVM
                }
            .disposed(by: self.rxDisposeBag)
        self.tableView.rx
            .modelSelected(RemoteUserViewModel.self)
            .subscribe(onNext: { [weak self] remoteUser in
                self?.searchTextField.resignFirstResponder()
                self?.selectedUser = remoteUser
                self?.runSegue(Constants.segueIDs.searchToDetails)
            })
            .disposed(by: self.rxDisposeBag)
        self.viewModel.onWillUpdateResults = { [weak self] in self?.applyUpdateResultsAnimation() }
    }
    
    
    // MARK: - Private
    
    private func applyUpdateResultsAnimation() {
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.2
        self.tableView.layer.add(transition, forKey: "transition")
    }
    
    private func runSearch() {
        self.viewModel.search(text: self.searchTextField.text!)
            .catch { error in self.handleError(error, completion: nil) }
    }

    private func clearResults() {
        self.applyUpdateResultsAnimation()
        self.viewModel.searchResults.value.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Constants.segueIDs.searchToDetails {
            let udVC = segue.destination as! SearchResultViewController
            udVC.remoteUser = self.selectedUser
        }
    }
    
}

extension SearchViewController: UITextFieldDelegate {
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text, text.count >= 3 else {
            clearResults()
            return
        }
        after(interval: 0.3)
            .then { _ -> Void in
                guard text == self.searchTextField.text else { throw NSError.cancelledError() }
            }
            .then { self.runSearch() }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
