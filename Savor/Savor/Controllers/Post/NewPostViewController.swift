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
import GooglePlaces
import CDYelpFusionKit
import IQKeyboardManagerSwift

class NewPostViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var restaurantAddressField: UITextField!
    @IBOutlet weak var restaurantNameField: UITextField!
    @IBOutlet weak var foodNameField: UITextField!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    let permissionCamera: Permission = .camera
    
    var isFindingOnYourLocation = true
    var place: GMSAutocompletePrediction?
    var business: CDYelpBusiness?
    var rating: Double = 0
    var descriptionText: String = ""
    var photos: [UIImage] = []
    
    var resultsController: UITableViewController!
    
    var placesClient: GMSPlacesClient!
    var fetcher: GMSAutocompleteFetcher!
    var filter: GMSAutocompleteFilter!
    var token: GMSAutocompleteSessionToken!
    var predictions: [GMSAutocompletePrediction] = []
    
    var completion: (() -> Void)?
    
    let currentlocationAttributedText = NSAttributedString.init(string: "Current Location",
                                                                              attributes: [.foregroundColor: UIColor.systemBlue])
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
        
        // iqkeyboardmanager
        IQKeyboardManager.shared.disabledTouchResignedClasses.append(NewPostViewController.self)
        
        // uitextfields
        self.restaurantAddressField.delegate = self
        self.restaurantAddressField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.restaurantNameField.delegate = self
        self.restaurantNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.foodNameField.delegate = self
        self.foodNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
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
        
        // resultscontroller setup
        self.resultsController = UITableViewController.init(style: .plain)
        self.resultsController.tableView.delegate = self
        self.resultsController.tableView.dataSource = self
        
        // gmsautocompletefetcher
        self.placesClient = GMSPlacesClient.shared()
        
        self.filter = GMSAutocompleteFilter.init()
        self.filter.type = .city
        
        self.token = GMSAutocompleteSessionToken.init()
        
        self.fetcher = GMSAutocompleteFetcher.init()
        self.fetcher.autocompleteFilter = filter
        self.fetcher.provide(token)
        self.fetcher.delegate = self
        
        self.refreshRestaurantAddressField()
    }
    
    func refreshRestaurantAddressField() {
        if isFindingOnYourLocation {
            // write current location
            self.restaurantAddressField.text = currentlocationAttributedText.string
            self.restaurantAddressField.attributedText = currentlocationAttributedText
            self.restaurantAddressField.clearsOnBeginEditing = true
        }
        else {
            if let place = self.place {
                // write the place
                let text = place.attributedFullText.string
                self.restaurantAddressField.text = text
                self.restaurantAddressField.attributedText = NSAttributedString.init(string: text,
                                                                                     attributes: [.foregroundColor: UIColor.black])
                self.restaurantAddressField.clearsOnBeginEditing = false
            } else {
                // remain the text user typed
                self.restaurantAddressField.clearsOnBeginEditing = false
            }
        }
    }
    
    func refreshRestaurantNameField() {
        
    }
    
    func refreshFoodNameField() {
        
    }
    
    func isLocationAvailable() -> Bool {
        return self.isFindingOnYourLocation || self.place != nil
    }
}

// MARK: - Actions
extension NewPostViewController {
    
    func cancelBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
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

// MARK: - UITextField
extension NewPostViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case restaurantAddressField:
            self.isFindingOnYourLocation = false
            self.restaurantAddressField.textColor = .black
            self.addResultsController()
            break
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField {
        case restaurantAddressField:
            if let text = restaurantAddressField.text, text.isWhitespace {
                self.isFindingOnYourLocation = true
                self.place = nil
                
                self.predictions.removeAll()
            }
            self.refreshRestaurantAddressField()
            self.dismissResultsController()
        default:
            break
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case restaurantAddressField:
            self.fetcher.sourceTextHasChanged(textField.text)
            break
        default:
            break
        }
    }
    
    func addResultsController() {
        self.addChild(resultsController)
        
        // Add the results controller.
        resultsController.view.translatesAutoresizingMaskIntoConstraints = false
        resultsController.view.alpha = 0.0
        self.view.addSubview(resultsController.view)

        // Layout it out below the text field using auto layout.
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[_searchField]-[resultView]-(0)-|",
                                                                 options: [],
                                                                 metrics: nil,
                                                                 views: ["_searchField" : restaurantAddressField!,
                                                                         "resultView" : resultsController.view!]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[resultView]-(0)-|",
                                                                options: [],
                                                                metrics: nil,
                                                                views: ["resultView" : resultsController.view!]))

        // Force a layout pass otherwise the table will animate in weirdly.
        self.view.layoutIfNeeded()

        // Reload the data.
        resultsController.tableView.reloadData()

        // Animate in the results.
        UIView.animate(withDuration: 0.3, animations: {
            self.resultsController.view.alpha = 1.0
        }) { (finished) in
            self.resultsController.didMove(toParent: self)
        }
    }
    
    func dismissResultsController() {
        // Dismiss the results.
        self.resultsController.willMove(toParent: nil)
        UIView.animate(withDuration: 0.3, animations: {
            self.resultsController.view.alpha = 0.0
        }) { (finished) in
            self.resultsController.view.removeFromSuperview()
            self.resultsController.removeFromParent()
        }
    }
}

// MARK: - GMSAutocompleteFetcher
extension NewPostViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        
        // store predictions
        self.predictions = predictions
        
        // resultscontroller reload
        self.resultsController.tableView.reloadData()
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print(error)
    }
}

// MARK: - UITableView
extension NewPostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.predictions.count + 1 /* current location */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = UITableViewCell.init()
            
            cell.textLabel?.text = self.currentlocationAttributedText.string
            cell.textLabel?.attributedText = self.currentlocationAttributedText
            
            return cell
            
        default:
            let cell = UITableViewCell.init()
            
            let prediction = self.predictions[indexPath.row - 1]
            
            let regularFont = cell.textLabel!.font!
            let boldFont = UIFont.boldSystemFont(ofSize: regularFont.pointSize)
            let bolded = NSMutableAttributedString.init(attributedString: prediction.attributedFullText)
            bolded.enumerateAttribute(.gmsAutocompleteMatchAttribute, in: NSMakeRange(0, bolded.length), options: []) { (value, range, stop) in
                let font = (value == nil) ? regularFont : boldFont
                bolded.addAttribute(.font, value: font, range: range)
            }
            
            cell.textLabel?.text = prediction.attributedFullText.string
            cell.textLabel?.attributedText = bolded
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            self.isFindingOnYourLocation = true
            self.place = nil
            
            self.predictions.removeAll()
            
        default:
            let prediction = self.predictions[indexPath.row - 1]
            
            self.isFindingOnYourLocation = false
            self.place = prediction
        }
        
        self.refreshRestaurantAddressField()
        self.dismissResultsController()
        self.restaurantAddressField.resignFirstResponder()
    }
}
