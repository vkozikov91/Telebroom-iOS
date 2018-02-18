//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class LoadingTableCell: UITableViewCell {
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) { }
    override func setSelected(_ selected: Bool, animated: Bool) { }
    
    class func loadFromXIB() -> LoadingTableCell {
        let xibName = String(describing: LoadingTableCell.self)
        let nib = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)!
        return nib.first as! LoadingTableCell
    }
    
    class func getHeight(visible: Bool) -> CGFloat {
        return visible ? 44.0 : 0.01
    }
    
}
