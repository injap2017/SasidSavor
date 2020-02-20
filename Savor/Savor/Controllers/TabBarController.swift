//
//  TabBarController.swift
//  Savor
//
//  Created by Edgar Sia on 15/01/2020.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit
import Permission
import GooglePlacesSearchController

class TabBarController: UITabBarController {
    
    // MARK: - Properties
    let permission: Permission = .camera
}

// MARK: - Lifecycle
extension TabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
}

// MARK: UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController is NewPostPlaceHolderViewController {
            //self.takePhoto()
            self.promptAuthentication()
            return false
        }
        
        return true
    }
}

// MARK: - Camera Roll
extension TabBarController {
    
    func takePhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary/*.camera*/) {
            switch self.permission.status {
            case .notDetermined, .denied, .disabled:
                self.requestPermission()
            case .authorized:
                self.cameraRoll()
            }
        }
    }
    
    func requestPermission() {
        let callBack: Permission.Callback = { status in
            switch status {
            case .authorized:
                self.cameraRoll()
            default:
                break
            }
        }
        
        self.permission.request(callBack)
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
}

// MARK: - UIImagePickerController Delegate
extension TabBarController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            // store photo
        }
        
        picker.dismiss(animated: true) {
            
        }
    }
}

// MARK: - Authentication
extension TabBarController {
    
    func promptAuthentication() {
        let alertController = UIAlertController.init(title: "New Post", message: "You must be a registered user to access this feature.", preferredStyle: .alert)
        let signUp = UIAlertAction.init(title: "Sign Up", style: .default) { (action) in
            let viewController = CreateNewAccountViewController.instanceOnNavigationController()
            self.present(viewController, animated: true, completion: nil)
        }
        let signIn = UIAlertAction.init(title: "Sign In", style: .default) { (action) in
            let viewController = SignInViewController.instanceOnNavigationController()
            self.present(viewController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(signUp)
        alertController.addAction(signIn)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
}
