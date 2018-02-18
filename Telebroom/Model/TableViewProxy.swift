//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

typealias TableViewProxyReuseIdentifierBinder = (AnyObject) -> String
typealias TableViewProxyItemBinder = (AnyObject, UITableViewCell) -> Void
typealias TableViewProxyCanEditItemHandler = (AnyObject) -> Bool
typealias TableViewProxyTapHandler = (AnyObject) -> Void
typealias TableViewProxyMoreContentHandler = () -> Void

class TableViewProxy {
    
    private weak var tableView: UITableView?
    
    private(set) var items = [AnyObject?]()
    var numberOfItems: Int { return items.count }
    
    
    // MARK: - Loading Cell
    
    var showsLoadingCell: Bool = false
    private var loadingCellRow: Int { return self.numberOfItems - 1 }
    private lazy var loadingCell: LoadingTableCell = {
        return LoadingTableCell.loadFromXIB()
    }()
    
    // MARK: - Configuration properties
    
    var reuseIdentifierBinder: TableViewProxyReuseIdentifierBinder?
    var itemBinder: TableViewProxyItemBinder?
    var canEditItemBinder: TableViewProxyCanEditItemHandler?
    var tapHandler: TableViewProxyTapHandler?
    var onMoreContentRequestedHandler: TableViewProxyMoreContentHandler?
    
    // MARK: - Init and Private
    
    init(for tableView: UITableView) {
        self.tableView = tableView
    }
    
    private func requestMoreContentIfNeeded() {
        guard self.numberOfItems > 1, self.showsLoadingCell else { return } // 1 is item for loading cell
        self.onMoreContentRequestedHandler?()
    }
    
    // MARK: - Items Operations
    
    func setItems(_ items: [AnyObject]) {
        var arr: [AnyObject?] = Array(items)
        arr.append(nil) // this nil object will be used for loading cell
        self.items = arr
        self.tableView?.reloadDataFadeAnimated()
    }
    
    func appendItems(_ items: [AnyObject?]) {
        self.items.insert(contentsOf: items, at: self.loadingCellRow)
        self.tableView?.reloadDataFadeAnimated()
    }
    
    func insertItem(_ item: AnyObject, with animation: UITableViewRowAnimation = .fade) {
        self.items.insert(item, at: 0)
        self.tableView?.insertRows(at: [IndexPath(row: 0, section: 0)], with: animation)
    }
    
    func updateItems(_ items: [AnyObject]?) {
        self.tableView?.reloadDataFadeAnimated()
    }

    // MARK: - Table View Delegate & Data Source
    
    func heightFor(_ row: Int) -> CGFloat {
        return row == self.loadingCellRow ? LoadingTableCell.getHeight(visible: self.showsLoadingCell) : UITableViewAutomaticDimension
    }
    
    func willDisplay(_ row: Int) {
        if row == self.loadingCellRow {
            self.requestMoreContentIfNeeded()
        }
    }
    
    func cellFor(_ row: Int) -> UITableViewCell {
        guard row != self.loadingCellRow else { return self.loadingCell }
        let item = items[row]!
        guard let reuseId = self.reuseIdentifierBinder?(item),
            let cell = tableView?.dequeueReusableCell(withIdentifier: reuseId, for: IndexPath(item: row, section: 0))
            else { fatalError("Invalid Table View Proxy Configuration") }
        self.itemBinder?(item, cell)
        return cell
    }
    
    func canEditRow(_ row: Int) -> Bool {
        guard row != self.loadingCellRow else { return false }
        return canEditItemBinder?(items[row]!) ?? false
    }
    
    func didSelect(_ row: Int) {
        self.tapHandler?(items[row]!)
    }
    
}
