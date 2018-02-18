//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    
    var viewModel: RemoteUserViewModel! {
        didSet { self.bindViewModel() }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = highlighted ? Theme.selectedCellBackgroundColor : UIColor.clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userImageView.image = #imageLiteral(resourceName: "img_user")
    }
    
    private func bindViewModel() {
        guard let vm = self.viewModel else { return }
        self.titleLabel.text = vm.fullName
        self.detailsLabel.text = vm.username
        self.userImageView.setImageAnimated(from:vm.fullImageUrl, placeholder: #imageLiteral(resourceName: "img_user"))
    }
    
}
