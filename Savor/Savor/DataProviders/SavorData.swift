//
//  SavorData.swift
//  Savor
//
//  Created by Edgar Sia on 3/2/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import Firebase
import arek
import MapKit

class SavorData {
    
    // MARK: - API Keys
    class APIKey {
        static let googlePlaces = "AIzaSyD0LCguIcWnEQYXrozUHD4mKa3U2CK9DKQ"
        static let yelp = "1mm0msj8c33c_6dMgNjlFX-GocP6_OW6yc-EwYFYEwI46YhCswKvsPHyTnEO6d8NfLYbK4nRW2BRxuk-9YEnoc2AxH6kYDlBuqVR0C6N6SNaD2TtvdxgvA34VYF2XnYx"
    }
    
    // MARK: - FireBase
    class FireBase {
        private static let storage = Storage.storage()
        private static let database = Database.database()
        
        // storage references
        class func profilePictureStorageReference(of uid: String) -> StorageReference {
            return storage.reference(withPath: "\(uid)/profilePicture/png")
        }
        
        class func postPictureFullStorageReference(of uid: String, postID: String, nth: Int) -> StorageReference {
            return storage.reference(withPath: "\(uid)/posts/\(postID)/full/jpg/\(nth)")
        }
        
        // firestore references
        static let rootReference = database.reference()
        static let postsReference = database.reference(withPath: "posts")
        static let restaurantsReference = database.reference(withPath: "restaurants")
        static let foodsReference = database.reference(withPath: "foods")
        static let feedReference = database.reference(withPath: "feed")
        static let peopleReference = database.reference(withPath: "people")
        static let savoredReference = database.reference(withPath: "savored")
    }

    // MARK: - Permission
    class Permission {
        private class func reEnablePopupData(for permission: String) -> ArekPopupData {
            return ArekPopupData.init(title: "\(permission) is currently disabled",
                                                              message: "Please enable access to \(permission) in the Settings app.",
                                                              allowButtonTitle: "Settings", denyButtonTitle: "Cancel",
                                                              type: .native)
        }
        
        private class func configuration() -> ArekConfiguration {
            return ArekConfiguration.init(frequency: .Always, presentInitialPopup: false, presentReEnablePopup: true)
        }
        
        static let photos = ArekPhoto.init(configuration: configuration(), initialPopupData: nil, reEnablePopupData: reEnablePopupData(for: "Photos"))
        static let camera = ArekCamera.init(configuration: configuration(), initialPopupData: nil, reEnablePopupData: reEnablePopupData(for: "Camera"))
        static let locationWhenInUse = ArekLocationWhenInUse.init(configuration: configuration(), initialPopupData: nil, reEnablePopupData: reEnablePopupData(for: "Location"))
    }
    
    // MARK: - Accessories
    class Accessories {
        class func timestampText(_ timestamp: Date) -> String {
            let now = Date()
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            let diff = Calendar.current.dateComponents(components, from: timestamp, to: now)
            
            var timeText = ""
            if diff.second! <= 0 {
                timeText = "Now"
            }
            if diff.second! > 0 && diff.minute! == 0 {
                timeText = (diff.second == 1) ? "\(diff.second!) second ago" : "\(diff.second!) seconds ago"
            }
            if diff.minute! > 0 && diff.hour! == 0 {
                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" : "\(diff.minute!) minutes ago"
            }
            if diff.hour! > 0 && diff.day! == 0 {
                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" : "\(diff.hour!) hours ago"
            }
            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                timeText = (diff.day == 1) ? "\(diff.day!) day ago" : "\(diff.day!) days ago"
            }
            if diff.weekOfMonth! > 0 {
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) week ago" : "\(diff.weekOfMonth!) weeks ago"
            }
            
            return timeText
        }
        
        class func countSuffix(_ count: Int) -> String {
            return (count > 1) ? "s" : ""
        }
        
        class func call(phoneNumber: String, on viewController: UIViewController) {
            if let phoneURL = NSURL(string: ("tel://" + phoneNumber)) {
                UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
            }
        }
        
        class func openMapForPlace(latitude: Double, longitude: Double, placeName: String, addressDictionary: [String: Any]? = nil) {
            let regionDistance: CLLocationDistance = 100
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: addressDictionary)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = placeName
            mapItem.openInMaps(launchOptions: options)
        }
        
        class func navigate(latitude: Double, longitude: Double, displayAddress: String, on viewController: UIViewController) {
            let destinationAddressForApple = displayAddress.replacingOccurrences(of: "\n", with: "%20").replacingOccurrences(of: " ", with: "%20")
            let destinationAddressForGoogle = displayAddress.replacingOccurrences(of: "\n", with: "+").replacingOccurrences(of: " ", with: "+")
            
            let appleURL = "http://maps.apple.com/?daddr=\(destinationAddressForApple)"
            let googleURL = "comgooglemaps://?daddr=\(destinationAddressForGoogle)&directionsmode=driving"
            let wazeURL = "waze://?ll=\(latitude),\(longitude)&navigate=false"
            
            let googleItem = ("Google Map", URL(string:googleURL)!)
            let wazeItem = ("Waze", URL(string:wazeURL)!)
            
            var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]
            
            if UIApplication.shared.canOpenURL(googleItem.1) {
                installedNavigationApps.append(googleItem)
            }
            
            if UIApplication.shared.canOpenURL(wazeItem.1) {
                installedNavigationApps.append(wazeItem)
            }
            
            let alert = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
            for app in installedNavigationApps {
                let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                    UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
                })
                alert.addAction(button)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            viewController.present(alert, animated: true)
        }
        
        class func visit(url: URL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
