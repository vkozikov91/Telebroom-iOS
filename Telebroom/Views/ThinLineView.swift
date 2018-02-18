//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import SnapKit

class ThinLineView: UIView {

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let heightConstraint = self.constraints.first(where: { $0.firstAttribute == .height }),
            heightConstraint.constant == 1
        {
            self.removeConstraint(heightConstraint)
            self.snp.makeConstraints { make in
                make.height.equalTo(1.0 / UIScreen.main.scale)
            }
        }
        if let widthConstraint = self.constraints.first(where: { $0.firstAttribute == .width }),
            widthConstraint.constant == 1
        {
            self.removeConstraint(widthConstraint)
            self.snp.makeConstraints { make in
                make.width.equalTo(1.0 / UIScreen.main.scale)
            }
        }
    }

}
