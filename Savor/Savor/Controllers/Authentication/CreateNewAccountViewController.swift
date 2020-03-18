//
//  CreateNewAccountViewController.swift
//  Savor
//
//  Created by Edgar Sia on 2/20/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import FirebaseAuth
import FirebaseStorage
import SwifterSwift
import Permission

class CreateNewAccountViewController: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var photoView: UIImageView!
    
    // MARK: - Properties
    let permissionCamera: Permission = .camera
    let permissionPhotos: Permission = .photos
    
    var firstNameInputCell: InputFieldCell?
    var lastNameInputCell: InputFieldCell?
    
    var userNameInputCell: InputFieldCell?
    var passwordInputCell: InputFieldCell?
    var confirmInputCell: InputFieldCell?
    
    var emailInputCell: InputFieldCell?
    
    var photo: UIImage?
    
    var firstName: String = ""
    var lastName: String = ""
    
    var userName: String = ""
    var password: String = ""
    var confirm: String = ""
    
    var email: String = ""
    
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    var completion: (() -> Void)?
}

// MARK: - Lifecycle
extension CreateNewAccountViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension CreateNewAccountViewController {
    
    class func instance(completion: @escaping () -> Void) -> CreateNewAccountViewController {
        let storyboard = UIStoryboard.init(name: "Authentication", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "createNewAccount") as! CreateNewAccountViewController
        viewController.completion = completion
        return viewController
    }
    
    class func instanceOnNavigationController(completion: @escaping () -> Void) -> UINavigationController {
        let viewController = self.instance(completion: completion)
        viewController.navigationItem.leftBarButtonItem = viewController.cancelBarButtonItem()
        let navigationController = UINavigationController.init(rootViewController: viewController)
        return navigationController
    }
    
    func initView() {
        // bar button item
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem()
        
        // title
        self.title = "Create New Account"
        
        // cell
        self.tableView.register(InputFieldCell.nib, forCellReuseIdentifier: InputFieldCell.identifier)
        
        // keyboard
        self.returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        self.returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        
        // profile photo
        self.photoView.image = photo
    }
}

// MARK: - Actions
extension CreateNewAccountViewController {
    
    func cancelBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
        return item
    }
    
    @objc func cancelAction() {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    func doneBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(self.doneAction))
        item.isEnabled = self.isCreateNewAccountActionAvailable()
        return item
    }
    
    @objc func doneAction() {
        
        self.createNewAccount()
    }
    
    @IBAction func profilePicture(_ sender: UIButton) {
        
        self.promptSourceType()
    }
}

// MARK: - TableView
extension CreateNewAccountViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 3
        default:
            return 1
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
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: InputFieldCell.identifier) as! InputFieldCell
            switch indexPath.row {
            case 0:
                cell.title = "User Name"
                cell.isRequired = true
                cell.value = self.userName
                cell.inputField.textContentType = .username
                cell.inputField.tag = 3
                cell.inputField.delegate = self
                self.returnKeyHandler.addTextFieldView(cell.inputField)
                self.userNameInputCell = cell
                
            case 1:
                cell.title = "Password"
                cell.isRequired = true
                cell.value = self.password
                cell.inputField.textContentType = .password
                cell.inputField.isSecureTextEntry = true
                cell.inputField.tag = 4
                cell.inputField.delegate = self
                self.returnKeyHandler.addTextFieldView(cell.inputField)
                self.passwordInputCell = cell
                
            default:
                cell.title = "Confirm"
                cell.isRequired = true
                cell.value = self.confirm
                cell.inputField.textContentType = .password
                cell.inputField.isSecureTextEntry = true
                cell.inputField.tag = 5
                cell.inputField.delegate = self
                self.returnKeyHandler.addTextFieldView(cell.inputField)
                self.confirmInputCell = cell
            }
            
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: InputFieldCell.identifier) as! InputFieldCell
            cell.title = "Email"
            cell.isRequired = true
            cell.value = self.email
            cell.inputField.textContentType = .emailAddress
            cell.inputField.keyboardType = .emailAddress
            cell.inputField.tag = 6
            cell.inputField.delegate = self
            self.returnKeyHandler.addTextFieldView(cell.inputField)
            self.emailInputCell = cell
            
            return cell
        }
    }
}

// MARK: - TextField
extension CreateNewAccountViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // disable username space input
        if textField == self.userNameInputCell?.inputField, string == " " {
            return false
        }
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            switch textField {
            case self.firstNameInputCell?.inputField:
                firstNameChanged(updatedText)
            case self.lastNameInputCell?.inputField:
                lastNameChanged(updatedText)
            case self.userNameInputCell?.inputField:
                userNameChanged(updatedText)
            case self.passwordInputCell?.inputField:
                passwordChanged(updatedText)
            case self.confirmInputCell?.inputField:
                confirmChanged(updatedText)
            case self.emailInputCell?.inputField:
                emailChanged(updatedText)
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
        case self.userNameInputCell?.inputField:
            userNameChanged("")
        case self.passwordInputCell?.inputField:
            passwordChanged("")
        case self.confirmInputCell?.inputField:
            confirmChanged("")
        case self.emailInputCell?.inputField:
            emailChanged("")
        default:
            break
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // done
        if textField == self.emailInputCell?.inputField, isCreateNewAccountActionAvailable() {
            
            self.createNewAccount()
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
    
    func userNameChanged(_ text: String) {
        self.userName = text
        // validate field
        valueChanged()
    }
    
    func passwordChanged(_ text: String) {
        self.password = text
        // validate field
        valueChanged()
    }
    
    func confirmChanged(_ text: String) {
        self.confirm = text
        // validate field
        valueChanged()
    }
    
    func emailChanged(_ text: String) {
        self.email = text
        // validate field
        valueChanged()
    }
    
    private func valueChanged() {
        self.navigationItem.rightBarButtonItem?.isEnabled = isCreateNewAccountActionAvailable()
    }
    
    private func isCreateNewAccountActionAvailable() -> Bool {
        guard  !self.firstName.isWhitespace
            && !self.lastName.isWhitespace
            && !self.userName.isWhitespace
            && !self.password.isEmpty
            && !self.confirm.isEmpty
            && !self.email.isWhitespace
            && self.photo != nil else {
                return false
        }
        
        // password equal to confirm
        // email validate
        return self.password == self.confirm
            && self.email.isValidEmail
    }
}

// MARK: - Server API Calls
extension CreateNewAccountViewController {
    
    func createNewAccount() {
        
        // trim
        self.firstName.trim()
        self.lastName.trim()
        
        SVProgressHUD.show(withStatus: "Creating new account...")
        
        // create user
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            
            if let user = result?.user {
                
                // upload profile picture
                if let photo = strongSelf.photo, let data = photo.jpegData(compressionQuality: 0.5) {
                    let reference = Storage.storage().reference().child("profilePictures").child("\(user.uid).png")
                    reference.putData(data, metadata: nil) { (metaData, error) in
                        
                        if let error = error {
                            print(error)
                            SVProgressHUD.showError(withStatus: error.localizedDescription)
                            return
                        }
                        
                        // get download URL
                        reference.downloadURL { (url, error) in
                            guard let photoURL = url else {
                                return
                            }
                            
                            // request profile change
                            let request = user.createProfileChangeRequest()
                            request.displayName = strongSelf.userName
                            request.photoURL = photoURL
                            request.commitChanges { (error) in
                                
                                if let error = error {
                                    print(error)
                                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                                    return
                                }
                                
                                SVProgressHUD.dismiss()
                                
                                strongSelf.cancelAction()
                                
                                DispatchQueue.main.async {
                                    strongSelf.completion?()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Camera Roll
extension CreateNewAccountViewController {
    
    func promptSourceType() {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let takePhoto = UIAlertAction.init(title: "Take Photo", style: .default) { (action) in
                switch self.permissionCamera.status {
                case .notDetermined, .denied, .disabled:
                    self.requestPermissionCamera()
                case .authorized:
                    self.cameraRoll()
                }
            }
            alertController.addAction(takePhoto)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let choosePhoto = UIAlertAction.init(title: "Choose Photo", style: .default) { (action) in
                switch self.permissionPhotos.status {
                case .notDetermined, .denied, .disabled:
                    self.requestPermissionPhotos()
                case .authorized:
                    self.photoLibrary()
                }
            }
            alertController.addAction(choosePhoto)
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
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
    
    func requestPermissionCamera() {
        let callBack: Permission.Callback = { status in
            switch status {
            case .authorized:
                self.cameraRoll()
            default:
                break
            }
        }
        
        self.permissionCamera.request(callBack)
    }
    
    func requestPermissionPhotos() {
        let callBack: Permission.Callback = { status in
            switch status {
            case .authorized:
                self.photoLibrary()
            default:
                break
            }
        }
        
        self.permissionPhotos.request(callBack)
    }
}

// MARK: - UIImagePickerController Delegate
extension CreateNewAccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            self.photo = image
            
            self.photoView.image = photo
            
            valueChanged()
        }
        
        picker.dismiss(animated: true) {
            
        }
    }
}
