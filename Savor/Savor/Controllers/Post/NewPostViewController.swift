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
import CDYelpFusionKit

class NewPostViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    let permissionCamera: Permission = .camera
    
    var business: CDYelpBusiness?
    var rating: Double = 0
    var descriptionText: String = ""
    var photos: [UIImage] = []
    
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
        self.cosmosView.rating = rating
        self.cosmosView.didFinishTouchingCosmos = { rating in
            self.rating = rating
        }
        
        // uitextview placeholder
        self.descriptionTextView.placeholder = "Comment (optional)"
        self.descriptionTextView.text = descriptionText
        
        // uicollectionview cell
        self.collectionView.register(AddPhotoItem.nib, forCellWithReuseIdentifier: AddPhotoItem.identifier)
        self.collectionView.register(PhotoItem.nib, forCellWithReuseIdentifier: PhotoItem.identifier)
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
        item.isEnabled = self.isNewPostActionAvailable()
        return item
    }
    
    @objc func postAction() {
        
    }
    
    @objc func addPhotoAction() {
        self.takePhoto()
    }
    
    @objc func deletePhotoAction(_ sender: UIButton) {
        let senderPosition = sender.convert(sender.center, to: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: senderPosition) else {
            return
        }
        
        // delete photo
        self.photos.remove(at: indexPath.row)
        
        // uicollectionview delete photo
        self.collectionView.deleteItems(at: [indexPath])
    }
}

// MARK: - TextView
extension NewPostViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let fullText = textView.text, let textRange = Range(range, in: fullText) {
            let updatedText = fullText.replacingCharacters(in: textRange, with: text)
            
            switch textView {
            case self.descriptionTextView:
                descriptionChanged(updatedText)
            default:
                break
            }
            
            return true
        }
        
        return false
    }
    
    func descriptionChanged(_ text: String) {
        self.descriptionText = text
        // validate field
        print(text)
        valueChanged()
    }
    
    private func valueChanged() {
        self.navigationItem.rightBarButtonItem?.isEnabled = isNewPostActionAvailable()
    }
    
    private func isNewPostActionAvailable() -> Bool {
        guard self.business != nil
            && self.rating > 0.0
            && self.descriptionText.isWhitespace
            && self.photos.count > 0 else {
                return false
        }
        
        return true
    }
}

// MARK: - UICollectionView
extension NewPostViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count + 1 /* plus item */
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // the last is plus item
        if indexPath.row == self.photos.count  {
            let item = collectionView.dequeueReusableCell(withReuseIdentifier: AddPhotoItem.identifier, for: indexPath) as! AddPhotoItem
            item.cameraRollButton.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
            return item
        }
        
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoItem.identifier, for: indexPath) as! PhotoItem
        item.deleteButton.addTarget(self, action: #selector(deletePhotoAction), for: .touchUpInside)
        item.image = self.photos[indexPath.row]
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let leftInset = layout.sectionInset.left
        let rightInset = layout.sectionInset.right
        let cellSpace = layout.minimumInteritemSpacing
        let collectionViewSize = collectionView.bounds.size
        
        let columnSize = CGFloat(3)
        
        let width = (collectionViewSize.width - leftInset - rightInset - (columnSize - 1) * cellSpace) / columnSize
        let height = width
        
        return CGSize.init(width: width, height: height)
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
            self.photos.append(image)
            
            // uicollectionview add photo to the last - 1
            let indexPath = IndexPath.init(row: self.photos.count - 1, section: 0)
            self.collectionView.insertItems(at: [indexPath])
        }
        
        picker.dismiss(animated: true) {
            
        }
    }
}
