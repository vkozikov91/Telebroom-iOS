//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import SnapKit

enum TelebroomBottomBarTab: Int {
    case search = 0
    case home
    case profile
}

protocol TelebroomBarTabSelectedDelegate: class {
    func onTabSelected(tab: TelebroomBottomBarTab)
}

class TelebroomTabBar: UITabBar {
    
    weak var tabSelectedDelegate: TelebroomBarTabSelectedDelegate?
    
    private var overlayView: TelebroomTabBarOverlayView!
    var showsUnreadMessages = false {
        didSet { self.updateOverlayView(showsUnreadMessages: showsUnreadMessages) }
    }
    
    // MARK: - Override and Init
    
    override var selectedItem: UITabBarItem? {
        didSet {
            guard overlayView != nil else { return }
            self.overlayView.highlightTab(TelebroomBottomBarTab.init(rawValue: selectedItem!.tag))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupBar()
    }
    
    // MARK: - Private
    
    private func setupBar() {
        self.overlayView = TelebroomTabBarOverlayView.loadFromXIB()
        self.addSubview(overlayView)
        self.overlayView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            var bottomInset: CGFloat = 0.0
            if #available(iOS 11.0, *) {
                bottomInset = UIApplication.shared.keyWindow!.safeAreaInsets.bottom
            }
            make.bottom.equalToSuperview().inset(bottomInset)
        }
        self.overlayView.onTabSelectedHandler = { [weak self] tab in
            self?.tabSelectedDelegate?.onTabSelected(tab: tab)
        }
        
        // Allow central button to overfall the bounds
        self.overlayView.clipsToBounds = false
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        
        // Hide border line
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
    }
    
    private func updateOverlayView(showsUnreadMessages: Bool) {
        showsUnreadMessages ? self.overlayView.showUnreadMessageIcon() : self.overlayView.hideUnreadMessageIcon()
    }
}
