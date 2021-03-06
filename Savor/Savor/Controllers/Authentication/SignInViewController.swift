//
//  SignInViewController.swift
//  Savor
//
//  Created by Edgar Sia on 2/20/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//


import UIKit
import IQKeyboardManagerSwift
import SVProgressHUD
import Firebase
import SwifterSwift

enum ViewPresentationStyle {
    case Push
    case Present
}

class SignInViewController: UITableViewController {

    // MARK: - Properties
    var emailInputCell: InputFieldCell?
    var passwordInputCell: InputFieldCell?
    var signInActionCell: ActionCell?
    
    var email: String = ""
    var password: String = ""
    
    var returnKeyHandler : IQKeyboardReturnKeyHandler!
    
    var presentationStyle : ViewPresentationStyle = .Push
    
    var completion: (() -> Void)?
}

// MARK: - Lifecycle
extension SignInViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension SignInViewController {
    
    class func instance(completion: @escaping () -> Void) -> SignInViewController {
        let storyboard = UIStoryboard.init(name: "Authentication", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "signIn") as! SignInViewController
        viewController.completion = completion
        return viewController
    }
    
    class func instanceOnNavigationController(completion: @escaping () -> Void) -> UINavigationController {
        let viewController = self.instance(completion: completion)
        viewController.navigationItem.leftBarButtonItem = viewController.cancelBarButtonItem()
        viewController.presentationStyle = .Present
        let navigationController = UINavigationController.init(rootViewController: viewController)
        return navigationController
    }
    
    func initView() {
        // title
        self.title = "Sign In"
        
        // cell
        self.tableView.register(InputFieldCell.nib, forCellReuseIdentifier: InputFieldCell.identifier)
        self.tableView.register(ActionCell.nib, forCellReuseIdentifier: ActionCell.identifier)
        
        // keyboard
        self.returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        self.returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
    }
}

// MARK: - Actions
extension SignInViewController {
    
    func cancelBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
        return item
    }
    
    @objc func cancelAction() {
        switch presentationStyle {
        case .Present:
            self.navigationController?.dismiss(animated: true, completion: {
                
            })
        default:
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - TableView
extension SignInViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
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
                cell.title = "Email"
                cell.isRequired = true
                cell.value = self.email
                cell.inputField.textContentType = .emailAddress
                cell.inputField.keyboardType = .emailAddress
                cell.inputField.tag = 1
                cell.inputField.delegate = self
                self.returnKeyHandler.addTextFieldView(cell.inputField)
                self.emailInputCell = cell
                
            default:
                cell.title = "Password"
                cell.isRequired = true
                cell.value = self.password
                cell.inputField.textContentType = .password
                cell.inputField.isSecureTextEntry = true
                cell.inputField.tag = 2
                cell.inputField.delegate = self
                self.returnKeyHandler.addTextFieldView(cell.inputField)
                self.passwordInputCell = cell
                
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
            cell.title = "Sign In"
            cell.isEnabled = self.isSignInActionAvailable()
            self.signInActionCell = cell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        default:
            tableView.deselectRow(at: indexPath, animated: false)
            
            self.signIn()
        }
    }
}

// MARK: - TextField
extension SignInViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            
            switch textField {
            case self.emailInputCell?.inputField:
                emailChanged(updatedText)
            case self.passwordInputCell?.inputField:
                passwordChanged(updatedText)
            default:
                break
            }
            
            return true
        }
        
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailInputCell?.inputField:
            emailChanged("")
        case self.passwordInputCell?.inputField:
            passwordChanged("")
        default:
            break
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // done
        if textField == self.passwordInputCell?.inputField, isSignInActionAvailable() {
            
            self.signIn()
        }
        
        return true
    }
    
    func emailChanged(_ text: String) {
        self.email = text
        // validate field
        valueChanged()
    }
    
    func passwordChanged(_ text: String) {
        self.password = text
        // validate field
        valueChanged()
    }
    
    private func valueChanged() {
        self.signInActionCell?.isEnabled = isSignInActionAvailable()
    }
    
    private func isSignInActionAvailable() -> Bool {
        guard  !self.email.isWhitespace
            && !self.password.isWhitespace else {
                return false
        }
        
        // email validate
        return self.email.isValidEmail
    }
}

// MARK: - Server API Calls
extension SignInViewController {
    
    func signIn() {
        
        SVProgressHUD.show(withStatus: "Signing in...")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                print(error)
                SVProgressHUD.showError(withStatus: "Invalid email or password entered. Please try again.")
                return
            }
            
            DispatchQueue.main.async {
                
                SVProgressHUD.dismiss()
                
                strongSelf.cancelAction()
                
                strongSelf.completion?()
            }
        }
    }
}
