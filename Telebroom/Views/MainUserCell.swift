//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit
import RxSwift

class MainUserCell: UITableViewCell {

    @IBOutlet private weak var userImageView: UIImageView!
    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var lastTextLabel: UILabel!
    @IBOutlet private weak var lastDateLabel: UILabel!
    
    @IBOutlet private weak var newMessageIcon: PopUpView!
    @IBOutlet private weak var onlineStatusIconView: PopUpView!
    
    private var rxDisposeBag = DisposeBag()
    
    var viewModel: RemoteUserViewModel! {
        didSet { self.bindViewModel() }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        contentView.backgroundColor = highlighted ? Theme.selectedCellBackgroundColor : UIColor.clear
    }
    
    override func prepareForReuse() {
        self.newMessageIcon.disappear()
        self.onlineStatusIconView.isHidden = false
        self.rxDisposeBag = DisposeBag()
    }
    
    private func bindViewModel() {
        guard let vm = self.viewModel else { return }
        self.userImageView.setImageAnimated(from: vm.fullImageUrl, placeholder: #imageLiteral(resourceName: "img_user"))
        vm.hasUnreadMessages
            .asObservable()
            .subscribe(onNext: { [weak self] hasNew in
                hasNew ? self?.newMessageIcon.appear() : self?.newMessageIcon.disappear()
            })
            .disposed(by: self.rxDisposeBag)
        vm.isOnline
            .asObservable()
            .subscribe(onNext: { [weak self] in self?.onlineStatusIconView.isHidden = !$0 })
            .disposed(by: self.rxDisposeBag)
        vm.lastMessage
            .asObservable()
            .subscribe(onNext: { [weak self] in self?.updateLastMessageData(from: $0) })
            .disposed(by: self.rxDisposeBag)
        self.userNameLabel.text = vm.fullName
        if !viewModel.verified {
            self.lastTextLabel.text = "Wants to start a conversation"
            self.lastDateLabel.text = ""
        }
        self.userNameLabel.alpha = viewModel.verified ? 1.0 : 0.4
        self.userImageView?.alpha = viewModel.verified ? 1.0 : 0.4
    }
    
    private func updateLastMessageData(from message: Message?) {
        self.lastDateLabel.text = message?.timePassed ?? ""
        guard message != nil else {
            self.lastTextLabel.text = ""
            return
        }
        guard self.lastTextLabel.text != message?.shortFormatText else {
            return
        }
        let skipAnimation = (self.lastTextLabel.text == nil)
        self.lastTextLabel.text = message?.shortFormatText
        if !skipAnimation {
            let transition = CATransition()
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromTop
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            self.lastTextLabel.layer.add(transition, forKey: "textTransition")
        }
    }
}
