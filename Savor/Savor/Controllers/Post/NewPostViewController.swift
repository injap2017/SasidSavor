//
//  NewPostViewController.swift
//  Savor
//
//  Created by Edgar Sia on 10/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import Cosmos
import UITextView_Placeholder
import GooglePlaces
import CDYelpFusionKit
import IQKeyboardManagerSwift
import Firebase
import SwiftLocation
import SnapKit
import SVProgressHUD

class NewPostViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var restaurantAddressField: UITextField!
    @IBOutlet weak var restaurantNameField: UITextField!
    @IBOutlet weak var foodNameField: UITextField!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var currentLocation: CLLocationCoordinate2D?
    var place: GMSPlace?
    var business: CDYelpBusiness?
    var food: SSFood?
    var rating: Double = 0
    var descriptionText: String = ""
    var photos: [UIImage] = []
    
    // gms places api
    var placesClient: GMSPlacesClient!
    var fetcher: GMSAutocompleteFetcher!
    var filter: GMSAutocompleteFilter!
    var token: GMSAutocompleteSessionToken!
    var placePredictions: [GMSAutocompletePrediction] = []
    
    // yelp fusion api
    var yelpClient: CDYelpAPIClient!
    var businessPredictions: [CDYelpBusiness] = []
    
    // food api
    var foodPredictions: [SSFood] = []
    
    // resultscontroller
    var activeField: UITextField!
    var resultsController: UITableView!
    
    // search debouncer
    let searchDelay: TimeInterval = 0.8
    var searchDebouncer: Debouncer!
    
    var completion: (() -> Void)?
    
    let currentlocationAttributedText = NSAttributedString.init(string: "Current Location",
                                                                              attributes: [.foregroundColor: UIColor.systemBlue])
    
    static let postNotification = "postNotification"
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
        
        self.refreshRestaurantAddressField()
        
        self.restaurantNameField.delegate = self
        self.restaurantNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.refreshRestaurantNameField()
        
        self.foodNameField.delegate = self
        self.foodNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.refreshFoodNameField()
        
        self.figureOutFieldsAvailability()
        
        // cosmos view for iOS 13
        self.cosmosView.settings.disablePanGestures = true
        self.cosmosView.rating = rating
        self.cosmosView.didFinishTouchingCosmos = { rating in
            self.rating = rating
            // post available or not
            self.valueChanged()
        }
        
        // uitextview placeholder
        self.descriptionTextView.placeholder = "Comment (optional)"
        self.descriptionTextView.text = descriptionText
        
        // uicollectionview cell
        self.collectionView.register(AddPhotoItem.nib, forCellWithReuseIdentifier: AddPhotoItem.identifier)
        self.collectionView.register(PhotoItem.nib, forCellWithReuseIdentifier: PhotoItem.identifier)
        
        // debouncer
        self.searchDebouncer = Debouncer.init(delay: searchDelay, handler: {})
        
        // gmsautocompletefetcher
        self.placesClient = GMSPlacesClient.shared()
        
        self.filter = GMSAutocompleteFilter.init()
        self.filter.type = .city
        
        self.token = GMSAutocompleteSessionToken.init()
        
        self.fetcher = GMSAutocompleteFetcher.init()
        self.fetcher.autocompleteFilter = filter
        self.fetcher.provide(token)
        self.fetcher.delegate = self
        
        // yelp fusion api
        self.yelpClient = CDYelpAPIClient.init(apiKey: SavorData.APIKey.yelp)
    }
    
    func isLocationAvailable() -> Bool {
        return self.place != nil || self.currentLocation != nil
    }
    
    func availableLocation() -> CLLocationCoordinate2D? {
        if let place = self.place {
            return place.coordinate
        } else if let location = self.currentLocation {
            return location
        } else {
            return nil
        }
    }
    
    func refreshRestaurantAddressField() {
        if let place = self.place {
            // write the place
            let text = place.formattedAddress ?? ""
            self.restaurantAddressField.text = text
            self.restaurantAddressField.attributedText = NSAttributedString.init(string: text,
                                                                                 attributes: [.foregroundColor: UIColor.black])
            self.restaurantAddressField.clearsOnBeginEditing = false
            // remain the last search history
        } else if self.currentLocation != nil {
            // write current location
            self.restaurantAddressField.text = currentlocationAttributedText.string
            self.restaurantAddressField.attributedText = currentlocationAttributedText
            self.restaurantAddressField.clearsOnBeginEditing = true
            // clean the search history
            self.placePredictions.removeAll()
        } else {
            // clean the text
            self.restaurantAddressField.text = nil
            self.restaurantAddressField.attributedText = nil
            // clean the search history
            self.placePredictions.removeAll()
        }
    }
    
    func refreshRestaurantNameField() {
        if let business = self.business {
            // write the business
            let text = business.name
            self.restaurantNameField.text = text
            // remain the last search history
        } else {
            // clean the text
            self.restaurantNameField.text = nil
            // clean the search history
            self.businessPredictions.removeAll()
        }
    }
    
    func refreshFoodNameField() {
        if let food = self.food {
            // write the food
            let text = food.name
            self.foodNameField.text = text
            // remain the last search history
        } else {
            // clean the text
            self.foodNameField.text = nil
            // clean the search history
            self.foodPredictions.removeAll()
        }
    }
    
    func figureOutFieldsAvailability() {
        // + address field is true
        self.restaurantNameField.isEnabled = isLocationAvailable()
        self.foodNameField.isEnabled = isLocationAvailable() && business != nil
    }
    
    private func valueChanged() {
        self.navigationItem.rightBarButtonItem?.isEnabled = isNewPostActionAvailable()
    }
    
    private func isNewPostActionAvailable() -> Bool {
        guard self.isLocationAvailable()
            && self.business != nil
            && self.food != nil
            && self.rating > 0.0
            && !self.descriptionText.isWhitespace
            && self.photos.count > 0 else {
                return false
        }
        
        return true
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
        
        SVProgressHUD.show(withStatus: "Posting...")
        
        let uid = SSUser.currentUser().uid
        let foodID = self.food!.foodID
        
        // create restaurant if not exist
        let restaurantID = self.business!.id! /* yelp business id equal to restaurant id in firestore */
        SavorData.FireBase.restaurantsReference.child(restaurantID).setValue(self.business!.document())
        
        // create post
        let postRef = SavorData.FireBase.postsReference.childByAutoId()
        let postID = postRef.key!
        
        // create resized photos
        var fullDatas: [Data] = []
        for photo in self.photos {
            if let fullData = photo.scaled(toHeight: 640)?.compressedData() {
                fullDatas.append(fullData)
            }
        }
        
        // upload photos
        var indexedFullURLs: [(Int, String, String)] = []
        
        let dispatchGroup = DispatchGroup()
        for (i, fullData) in fullDatas.enumerated() {
            dispatchGroup.enter()
            
            let fullRef = SavorData.FireBase.postPictureFullStorageReference(of: uid, postID: postID, nth: i)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            fullRef.putData(fullData, metadata: metadata) { (metaData, error) in
                if let error = error {
                    dispatchGroup.leave()
                    print(error)
                    return
                }
                fullRef.downloadURL { (url, error) in
                    if let error = error {
                        dispatchGroup.leave()
                        print(error)
                        return
                    }
                    if let url = url?.absoluteString {
                        indexedFullURLs.append((i, url, fullRef.fullPath))
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            
            // sort photo URLs
            let sortedIndexedFullURLs = indexedFullURLs.sorted { (first, second) -> Bool in
                return first.0 < second.0
            }
            
            // create photo URLs
            var fullURLs: [[String: String]] = []
            for url in sortedIndexedFullURLs {
                fullURLs.append(["full_url": url.1, "full_storage_uri": url.2])
            }
            
            // set post data
            let timestamp = Date().timeIntervalSince1970
            let data = ["text": self.descriptionText,
                        "rating": self.rating,
                        "photos": fullURLs,
                        "author": SSUser.currentUser().author(),
                        "restaurant": self.business!.partialDocument(),
                        "food": self.food!.partialDocument(),
                        "timestamp": timestamp] as [String: Any]
            
            postRef.setValue(data)
            
            // remark the post in user/posts (to show this post in user profile) and feed/user (to show this post in this user feed)
            SavorData.FireBase.rootReference.updateChildValues(["people/\(uid)/posts/\(postID)": true,
                                                                "feed/\(uid)/\(postID)": true])
            // remark the food savored as rating (calculate total rating, add postID)
            APIs.Savored.savored(foodID: foodID, in: restaurantID, postID: postID, rating: self.rating, timestamp: timestamp) { (error) in
                if let error = error {
                    print(error)
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                    return
                }
                
                SVProgressHUD.dismiss()
                
                self.cancelAction()
                
                DispatchQueue.main.async {
                    self.completion?()
                }
            }
        }
    }
    
    @objc func addPhotoAction() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.askPermissionIfOKThenCameraRoll()
        }
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
        
        // post available or not
        self.valueChanged()
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
    
    func askPermissionIfOKThenCameraRoll() {
        SavorData.Permission.camera.manage { (status) in
            DispatchQueue.main.async {
                if status == .authorized { self.cameraRoll() }
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
            
            // post available or not
            self.valueChanged()
        }
        
        picker.dismiss(animated: true) {
            
        }
    }
}

// MARK: - GPS
extension NewPostViewController {
    
    func askPermissionIfOKThenGetCurrentLocation(completion: @escaping (_ location: CLLocation?) -> Void) {
        SavorData.Permission.locationWhenInUse.manage { (status) in
            if status == .authorized {
                LocationManager.shared.locateFromGPS(.oneShot, accuracy: .room) { result in
                    switch result {
                    case .success(let location):
                        completion(location)
                    case .failure(let reason):
                        print(reason)
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - UITextField
extension NewPostViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case restaurantAddressField:
            // input text color to be black otherwise current location
            self.restaurantAddressField.textColor = .black
            
            self.showResultsController(under: restaurantAddressField)
            
        case restaurantNameField:
            self.showResultsController(under: restaurantNameField)
            
        case foodNameField:
            self.showResultsController(under: foodNameField)
            
        default:
            break
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        // debounce handler
        var debounceHandler: () -> Void = {}

        switch textField {
        case restaurantAddressField:
            debounceHandler = {
                self.fetcher.sourceTextHasChanged(textField.text)
            }

        case restaurantNameField:
            guard let locationCoordinate = self.availableLocation() else {
                return
            }
            
            debounceHandler = {
                self.yelpClient.searchBusinesses(byTerm: textField.text,
                                                 location: nil,
                                                 latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, radius: nil,
                                                 categories: nil,
                                                 locale: nil,
                                                 limit: nil, offset: nil,
                                                 sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil, attributes: nil,
                                                 completion: self.didYelpSearchComplete(_:))
            }

        case foodNameField:
            debounceHandler = {
                SavorData.FireBase.foodsReference.observeSingleEvent(of: .value, with: self.didFoodSearchComplete)
            }
            
        default:
            break
        }
        
        // invalidate the current debouncer so that it doesn't execute the old handler
        self.searchDebouncer.invalidate()
        self.searchDebouncer.handler = debounceHandler
        self.searchDebouncer.call()
    }
}

// MARK: - ResultsController
extension NewPostViewController {
    
    func showResultsController(under textField: UITextField) {
        // Dismiss the results controller
        self.dismissResultsControllerIfNeeded()
        
        // Add the results controller.
        self.activeField = textField
        
        self.resultsController = UITableView.init()
        self.resultsController.delegate = self
        self.resultsController.dataSource = self
        
        resultsController.translatesAutoresizingMaskIntoConstraints = false
        resultsController.keyboardDismissMode = .onDrag
        self.view.addSubview(resultsController)
        
        // Layout it out below the text field using auto layout.
        resultsController.snp.makeConstraints { (maker) in
            maker.top.equalTo(textField.snp.bottom).offset(0.5) /* separator */
            maker.leading.equalToSuperview()
            maker.trailing.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
        
        // Force a layout pass otherwise the table will animate in weirdly.
        self.view.layoutIfNeeded()
        
        // Reload the data.
        resultsController.reloadData()
    }
    
    func dismissResultsControllerIfNeeded() {
        // Dismiss the results.
        if self.activeField != nil
            && self.resultsController != nil {
            
            self.activeField = nil
            
            self.resultsController.removeFromSuperview()
            self.resultsController = nil
        }
    }
}

// MARK: - GMSAutocompleteFetcher
extension NewPostViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        
        // store predictions
        self.placePredictions = predictions
        
        // resultscontroller reload
        if self.activeField == restaurantAddressField
            && self.resultsController != nil {
            self.resultsController?.reloadData()
        } else {
            print("other field activated")
        }
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
        print(error)
    }
}

// MARK: - CDYelpFusionAPI Autocomplete
extension NewPostViewController {
    func didYelpSearchComplete(_ response: CDYelpSearchResponse?) {
        if let response = response,
            let businesses = response.businesses,
            businesses.count > 0 {
            
            // store predictions
            self.businessPredictions = businesses

            // resultscontroller reload
            if self.activeField == restaurantNameField
                && self.resultsController != nil {
                self.resultsController?.reloadData()
            } else {
                print("other field activated")
            }
        }
    }
}

// MARK: - Food API Autocomplete
extension NewPostViewController {
    func didFoodSearchComplete(snapshot: DataSnapshot) {
        
        // retrieve food predictions
        var foodPredictions: [SSFood] = []
        for snap in snapshot.children {
            let food = SSFood.init(snapshot: snap as! DataSnapshot)
            foodPredictions.append(food)
        }
        
        // store predictions
        self.foodPredictions = foodPredictions
        
        // resultscontroller reload
        if self.activeField == foodNameField
            && self.resultsController != nil {
            self.resultsController?.reloadData()
        } else {
            print("other field activated")
        }
    }
}

// MARK: - UITableView
extension NewPostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activeField {
        case restaurantAddressField:
            return self.placePredictions.count + 1 /* current location */
        case restaurantNameField:
            return self.businessPredictions.count
        default:
            return self.foodPredictions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch activeField {
        case restaurantAddressField:
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "placePredictionsCell")
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = self.currentlocationAttributedText.string
                cell.textLabel?.attributedText = self.currentlocationAttributedText
                
                return cell
                
            default:
                let prediction = self.placePredictions[indexPath.row - 1]/* current location */
                
                cell.textLabel?.text = prediction.attributedFullText.string
                cell.textLabel?.attributedText = prediction.attributedFullText
                
                return cell
            }
        case restaurantNameField:
            let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "businessPredictionsCell")
            
            let prediction = self.businessPredictions[indexPath.row]
            
            cell.textLabel?.text = prediction.name
            cell.detailTextLabel?.text = prediction.detailAddress()
            
            return cell
            
        default:
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "foodPredictionsCell")
            
            let prediction = self.foodPredictions[indexPath.row]
            
            cell.textLabel?.text = prediction.name
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch activeField {
        case restaurantAddressField:
            switch indexPath.row {
            case 0:
                self.place = nil
                
                // if current location nil, then try to get
                if self.currentLocation == nil {
                    self.askPermissionIfOKThenGetCurrentLocation { (location) in
                        if let location = location {
                            DispatchQueue.main.async {
                                
                                // store location
                                self.currentLocation = location.coordinate
                                
                                // clean under values
                                self.business = nil
                                self.food = nil
                                
                                self.restaurantAddressField.resignFirstResponder()
                                self.dismissResultsControllerIfNeeded()
                                
                                self.refreshRestaurantAddressField()
                                self.refreshRestaurantNameField()
                                self.refreshFoodNameField()
                                
                                self.figureOutFieldsAvailability()
                                
                                // post available or not
                                self.valueChanged()
                            }
                        }
                    }
                } else {
                    
                    // clean under values
                    self.business = nil
                    self.food = nil
                    
                    self.restaurantAddressField.resignFirstResponder()
                    self.dismissResultsControllerIfNeeded()
                    
                    self.refreshRestaurantAddressField()
                    self.refreshRestaurantNameField()
                    self.refreshFoodNameField()
                    
                    self.figureOutFieldsAvailability()
                    
                    // post available or not
                    self.valueChanged()
                }
                
            default:
                let prediction = self.placePredictions[indexPath.row - 1]/* current location */
                
                // fetch place details
                let fields: GMSPlaceField = GMSPlaceField.init(rawValue:
                        GMSPlaceField.placeID.rawValue |
                        GMSPlaceField.coordinate.rawValue |
                        GMSPlaceField.formattedAddress.rawValue)!
                self.placesClient.fetchPlace(fromPlaceID: prediction.placeID, placeFields: fields, sessionToken: token) { (place, error) in
                    if let place = place {
                        
                        // store place
                        self.place = place
                        
                        // clean under values
                        self.business = nil
                        self.food = nil
                        
                        self.restaurantAddressField.resignFirstResponder()
                        self.dismissResultsControllerIfNeeded()
                        
                        self.refreshRestaurantAddressField()
                        self.refreshRestaurantNameField()
                        self.refreshFoodNameField()
                        
                        self.figureOutFieldsAvailability()
                        
                        // post available or not
                        self.valueChanged()
                    }
                }
            }
            
        case restaurantNameField:
            let prediction = self.businessPredictions[indexPath.row]
            
            // store business
            self.business = prediction
            
            // clean under values
            self.food = nil
            
            self.restaurantNameField.resignFirstResponder()
            self.dismissResultsControllerIfNeeded()
            
            self.refreshRestaurantNameField()
            self.refreshFoodNameField()
            
            self.figureOutFieldsAvailability()
            
            // post available or not
            self.valueChanged()
            
        default:
            let prediction = self.foodPredictions[indexPath.row]
            
            // store food
            self.food = prediction
            
            self.foodNameField.resignFirstResponder()
            self.dismissResultsControllerIfNeeded()
            
            self.refreshFoodNameField()
            
            // post available or not
            self.valueChanged()
        }
    }
}
