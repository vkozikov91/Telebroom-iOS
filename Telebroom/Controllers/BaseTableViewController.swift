//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class BaseTableViewController: BaseViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var tableViewProxy: TableViewProxy! {
        didSet {
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 100.0
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        self.configureTableView()
        super.viewDidLoad()
    }
    
    override func decorateViewController() {
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    open func configureTableView() {
        self.bindTableView()
    }
    
    open func bindTableView() {
        let ibTableView = view.subviews.first(where: { $0 is UITableView })
        self.tableView = ibTableView as! UITableView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Table View Delegation

extension BaseTableViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewProxy.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableViewProxy.heightFor(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.tableViewProxy.cellFor(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableViewProxy.willDisplay(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        self.tableViewProxy.didSelect(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.tableViewProxy.canEditRow(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
}

// MARK: - Content Animated Reloading

extension UITableView {
    func reloadDataFadeAnimated() {
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.1
        self.layer.add(transition, forKey: "transition")
        self.reloadData()
    }
}
