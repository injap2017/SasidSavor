//
//  EditProfileViewController.swift
//  Savor
//
//  Created by Edgar Sia on 6/1/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import SDWebImage
import Firebase

class EditProfileViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var photoView: UIImageView!
    
    // MARK: - Properties
    var firstNameInputCell: InputFieldCell?
    var lastNameInputCell: InputFieldCell?
    
    var user: SSUser!
    
    var photo: UIImage?
    
    var firstName: String = ""
    var lastName: String = ""
    
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    var hasChanges: Bool = false
    var hasProfilePhotoChanged: Bool = false
    
    static let editNotification = "editNotification"
}

// MARK: - Lifecycle
extension EditProfileViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension EditProfileViewController {
    
    class func instance(user: SSUser) -> EditProfileViewController {
        let storyboard = UIStoryboard.init(name: "Profile", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "editProfile") as! EditProfileViewController
        viewController.user = user
        return viewController
    }
    
    class func instanceOnNavigationController(user: SSUser) -> UINavigationController {
        let viewController = self.instance(user: user)
        viewController.navigationItem.leftBarButtonItem = viewController.cancelBarButtonItem()
        let navigationController = UINavigationController.init(rootViewController: viewController)
        return navigationController
    }
    
    class func syncData(completion: @escaping (UINavigationController) -> Void) {
        // load current user
        var user: SSUser?
        
        APIs.Users.getUser(of: SSUser.authCurrentUser.uid) { (_user) in
            user = _user
            
            // go to edit profile
            let viewController = EditProfileViewController.instanceOnNavigationController(user: user!)
            
            completion(viewController)
        }
    }
    
    func initView() {
        // bar button item
        self.navigationItem.rightBarButtonItem = self.saveBarButtonItem()
        
        // title
        self.title = "Account Info"
        
        // cell
        self.tableView.register(InputFieldCell.nib, forCellReuseIdentifier: InputFieldCell.identifier)
        
        // keyboard
        self.returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        self.returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        // initial populate data
        if let pictureURL = user.profilePictureURL {
            self.photoView.sd_setImage(with: pictureURL) { (image, error, cacheType, url) in
                if let image = image {
                    self.photo = image
                }
            }
        }
        self.firstName = user.firstName
        self.lastName = user.lastName
    }
}

// MARK: - Actions
extension EditProfileViewController {
    
    func cancelBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
        return item
    }
    
    @objc func cancelAction() {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    func saveBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(self.saveAction))
        item.isEnabled = self.isSaveActionAvailable()
        return item
    }
    
    @objc func saveAction() {
        
        self.save()
    }
    
    @IBAction func profilePicture(_ sender: UIButton) {
        
        self.promptSourceType()
    }
}

// MARK: - TableView
extension EditProfileViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: InputFieldCell.identifier) as! InputFieldCell
            switch indexPath.row {
            case 0:
                cell.title = "First Name"
                cell.isRequired = true
                cell.value = self.firstName
                cell.inputField.textContentType = .givenName
                cell.inputField.tag = 1
                cell.inputField.delegate = self
                self.returnKeyHandler.addTextFieldView(cell.inputField)
                self.firstNameInputCell = cell
                
            default:
                cell.title = "Last Name"
                cell.isRequired = true
                cell.value = self.lastName
                cell.inputField.textContentType = .familyName
                cell.inputField.tag = 2
                cell.inputField.delegate = self
                self.returnKeyHandler.addTextFieldView(cell.inputField)
                self.lastNameInputCell = cell
            }
            
            return cell
            
        default:
            return UITableViewCell.init()
        }
    }
}

// MARK: - TextField
extension EditProfileViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            switch textField {
            case self.firstNameInputCell?.inputField:
                firstNameChanged(updatedText)
            case self.lastNameInputCell?.inputField:
                lastNameChanged(updatedText)
            default:
                break
            }
            
            return true
        }
        
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.firstNameInputCell?.inputField:
            firstNameChanged("")
        case self.lastNameInputCell?.inputField:
            lastNameChanged("")
        default:
            break
        }
        
        return true
    }
    
    func firstNameChanged(_ text: String) {
        self.firstName = text
        // validate field
        valueChanged()
    }
    
    func lastNameChanged(_ text: String) {
        self.lastName = text
        // validate field
        valueChanged()
    }
    
    private func valueChanged() {
        self.hasChanges = true
        
        self.navigationItem.rightBarButtonItem?.isEnabled = isSaveActionAvailable()
    }
    
    private func isSaveActionAvailable() -> Bool {
        guard  !self.firstName.isWhitespace
            && !self.lastName.isWhitespace
            /*&& self.photo != nil*/ else {
                return false
        }
        
        return self.hasChanges
    }
}

// MARK: - Server API Calls
extension EditProfileViewController {
    
    func save() {
        
        // trim
        self.firstName.trim()
        self.lastName.trim()
        
        if hasProfilePhotoChanged, let photo = self.photo, let user = self.user, let oldURL = user.profilePictureURL, let authUser = Auth.auth().currentUser {
            
            SVProgressHUD.show(withStatus: "Saving...")
            
            // update photo
            APIs.ProfilePictures.uploadPhoto(photo, ofUser: user.uid) { (url, error) in
                if let error = error {
                    print(error)
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    return
                }
                
                // request profile change
                authUser.requestProfileChange(photoURL: url) { (error) in
                    if let error = error {
                        print(error)
                        SVProgressHUD.showError(withStatus: error.localizedDescription)
                        return
                    }
                    
                    // remove sdwebimage cache
                    SDImageCache.shared.removeImage(forKey: oldURL.absoluteString) {
                        
                        // update user profile
                        self.user.firstName = self.firstName
                        self.user.lastName = self.lastName
                        self.user.profilePictureURL = url
                        
                        APIs.Users.setUser(self.user)
                        
                        DispatchQueue.main.async {
                            
                            SVProgressHUD.dismiss()
                            
                            // notify profile view needs to display changes
                            NotificationCenter.default.post(name: Notification.Name.init(EditProfileViewController.editNotification), object: nil)
                            
                            self.cancelAction()
                        }
                    }
                }
            }
        }
        else {
            // update user profile
            self.user.firstName = self.firstName
            self.user.lastName = self.lastName
            
            APIs.Users.setUser(self.user)
            
            // notify profile view needs to display changes
            NotificationCenter.default.post(name: Notification.Name.init(EditProfileViewController.editNotification), object: nil)
            
            self.cancelAction()
        }
    }
}

// MARK: - Camera Roll
extension EditProfileViewController {
    
    func promptSourceType() {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let takePhoto = UIAlertAction.init(title: "Take Photo", style: .default) { (action) in
                self.askPermissionIfOKThenCameraRoll()
            }
            alertController.addAction(takePhoto)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let choosePhoto = UIAlertAction.init(title: "Choose Photo", style: .default) { (action) in
                self.askPermissionIfOKThenPhotoLibrary()
            }
            alertController.addAction(choosePhoto)
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func askPermissionIfOKThenCameraRoll() {
        SavorData.Permission.camera.manage { (status) in
            DispatchQueue.main.async {
                if status == .authorized { self.cameraRoll() }
            }
        }
    }
    
    func askPermissionIfOKThenPhotoLibrary() {
        SavorData.Permission.photos.manage { (status) in
            DispatchQueue.main.async {
                if status == .authorized { self.photoLibrary() }
            }
        }
    }
    
    func cameraRoll() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        
        self.present(imagePicker, animated: true) {
            
        }
    }
    
    func photoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        
        self.present(imagePicker, animated: true) {
            
        }
    }
}

// MARK: - UIImagePickerController Delegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            self.photo = image
            
            self.photoView.image = photo
            
            self.hasProfilePhotoChanged = true
            
            valueChanged()
        }
        
        picker.dismiss(animated: true) {
            
        }
    }
}
