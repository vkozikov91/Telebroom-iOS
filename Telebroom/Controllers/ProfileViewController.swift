//
//  Copyright © 2017 Vladimir Kozikov. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var avatarBackgroundImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var firstNameLabel: UILabel!
    @IBOutlet private weak var secondNameLabel: UILabel!
    
    private var profileService: ProfileService!
    private var credentialsToEdit: CredentialsType?
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureServices()
        setNameLabels()
        setLocalUserImage()
    }
    
    override func decorateViewController() {
        super.decorateViewController()
        self.view.backgroundColor = Theme.mainColor
    }
    
    // MARK: - Private
    
    private var localUser: LocalUser {
        return self.profileService.repository.localUser!
    }
    
    private func configureServices() {
        self.profileService = router.serviceFactory.getProfileService()
    }

    private func setLocalUserImage() {
        guard let user = profileService.repository.localUser else { return }
        self.avatarImageView.setImageAnimated(from: user.fullImageUrl, placeholder: #imageLiteral(resourceName: "img_user"))
        self.avatarBackgroundImageView.setImageAnimated(from: user.fullImageUrl, placeholder: #imageLiteral(resourceName: "img_user"))
    }
    
    private func setNameLabels() {
        guard let user = profileService.repository.localUser else { return }
        self.usernameLabel.text = user.username
        self.firstNameLabel.text = user.firstname
        self.secondNameLabel.text = user.secondname
    }
    
    private func pickNewProfileImage() {
        ImagePickerManager.openPicker(from: self) { image in
            if let image = image {
                self.updateProfileImage(image)
            }
        }
    }
    
    private func updateProfileImage(_ image: UIImage) {
        self.avatarImageView.setImageAnimated(image)
        self.avatarBackgroundImageView.setImageAnimated(image)
        self.profileService.uploadAvatar(image)
            .catch { error in
                self.handleError(error, completion: nil)
                self.setLocalUserImage()
            }
    }
    
    // MARK: - IBActions
    
    @IBAction func onEditAvatarPressed(_ sender: UIButton) {
        self.pickNewProfileImage()
    }
    
    @IBAction func onLogoutPressed(_ sender: UIButton) {
        self.profileService.logout()
        self.router.resetApp()
    }
    
    @IBAction func onFirstNameTapGesture(_ sender: UITapGestureRecognizer) {
        self.credentialsToEdit = .firstname
        self.runSegue(Constants.segueIDs.profileToEdit)
    }
    
    @IBAction func onSecondNameTapGesture(_ sender: UITapGestureRecognizer) {
        self.credentialsToEdit = .secondname
        self.runSegue(Constants.segueIDs.profileToEdit)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == Constants.segueIDs.profileToEdit {
            let ecVC = segue.destination as! EditCredentialsViewController
            switch self.credentialsToEdit! {
            case .firstname:
                ecVC.credentialsTitle = "First name"
                ecVC.valueToChange = self.localUser.firstname
            case .secondname:
                ecVC.credentialsTitle = "Second name"
                ecVC.valueToChange = self.localUser.secondname
            }
        }
    }
    
    @IBAction private func onUnwindToProfile(segue: UIStoryboardSegue) {
        if segue.identifier == Constants.segueIDs.unwindEditCredentialsToProfile {
            let ecVC = segue.source as! EditCredentialsViewController
            var firstname = self.localUser.firstname
            var secondname = self.localUser.secondname
            switch self.credentialsToEdit! {
                case .firstname:
                    firstname = ecVC.valueToChange
                case .secondname:
                    secondname = ecVC.valueToChange
            }
            self.firstNameLabel.text = firstname
            self.secondNameLabel.text = secondname
            self.profileService.changeUserInfo(firstname: firstname, secondname: secondname)
                .catch { error in
                    self.handleError(error, completion: nil)
                    self.setNameLabels()
                }
        }
    }
}
