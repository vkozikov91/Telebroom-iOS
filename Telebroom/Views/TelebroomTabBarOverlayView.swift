//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class TelebroomTabBarOverlayView: UIView {
    
    @IBOutlet private weak var searchButton: BubbleButton!
    @IBOutlet private weak var homeButton: HomeTabBarButton!
    @IBOutlet private weak var profileButton: BubbleButton!
    @IBOutlet private weak var topLineView: UIView!
    
    var onTabSelectedHandler: ((TelebroomBottomBarTab) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    class func loadFromXIB() -> TelebroomTabBarOverlayView {
        let xibName = String(describing: TelebroomTabBarOverlayView.self)
        let nib = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)!
        return nib.first as! TelebroomTabBarOverlayView
    }
    
    public func highlightTab(_ tab: TelebroomBottomBarTab?) {
        [searchButton, homeButton, profileButton].forEach { $0.isSelected = (tab?.rawValue == $0.tag) }
    }
    
    public func showUnreadMessageIcon() {
        self.homeButton.showUnreadMessageIcon()
    }
    
    public func hideUnreadMessageIcon() {
        self.homeButton.hideUnreadMessageIcon()
    }
    
    // MARK: -
    
    private func setupView() {
        self.topLineView.backgroundColor = Theme.tabBarBorderColor
        self.decorateButton(self.searchButton, normalImage: #imageLiteral(resourceName: "btn_search_off"), activeImage: #imageLiteral(resourceName: "btn_search_on"))
        self.decorateButton(self.homeButton, normalImage: #imageLiteral(resourceName: "btn_home_off"), activeImage: #imageLiteral(resourceName: "btn_home_on"))
        self.decorateButton(self.profileButton, normalImage: #imageLiteral(resourceName: "btn_profile_off"), activeImage: #imageLiteral(resourceName: "btn_profile_on"))
    }
    
    private func decorateButton(_ button: UIButton, normalImage: UIImage, activeImage: UIImage) {
        button.setImage(normalImage, for: .normal)
        button.setImage(activeImage, for: .selected)
    }
    
    // MARK:- IBActions
    
    @IBAction func onSearchButtonTapped(_ sender: UIButton) {
        self.onTabSelectedHandler?(.search)
    }
    
    @IBAction func onHomeButtonTapped(_ sender: UIButton) {
        self.onTabSelectedHandler?(.home)
    }
    
    @IBAction func onProfileButtonTapped(_ sender: UIButton) {
        self.onTabSelectedHandler?(.profile)
    }
}
