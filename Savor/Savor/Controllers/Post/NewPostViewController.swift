//
//  NewPostViewController.swift
//  Savor
//
//  Created by Edgar Sia on 10/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import Permission
import Cosmos
import UITextView_Placeholder

class NewPostViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Properties
    let permissionCamera: Permission = .camera
    
    var completion: (() -> Void)?
}

// MARK: - Lifecycle
extension NewPostViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
    }
}

// MARK: - Functions
extension NewPostViewController {
    
    private class func instance(completion: @escaping () -> Void) -> NewPostViewController {
        let storyboard = UIStoryboard.init(name: "NewPost", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "newPost") as! NewPostViewController
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
        self.navigationItem.rightBarButtonItem = self.postBarButtonItem()
        
        // title
        self.title = "New Post"
        
        // cosmos view for iOS 13
        self.cosmosView.settings.disablePanGestures = true
        
        // uitextview placeholder
        self.descriptionTextView.placeholder = "Comment (optional)"
    }
}

// MARK: - Actions
extension NewPostViewController {
    
    func cancelBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
        return item
    }
    
    @objc func cancelAction() {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    func postBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(title: "Post", style: .done, target: self, action: #selector(postAction))
        // post is enabled?
        return item
    }
    
    @objc func postAction() {
        
    }
}

// MARK: - Camera Roll
extension NewPostViewController {
    
    func takePhoto() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            switch self.permissionCamera.status {
            case .notDetermined, .denied, .disabled:
                self.requestPermissionCamera()
            case .authorized:
                self.cameraRoll()
            }
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
extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            // store photo
        }
        
        picker.dismiss(animated: true) {
            
        }
    }
}
