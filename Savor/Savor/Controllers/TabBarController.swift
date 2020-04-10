//
//  TabBarController.swift
//  Savor
//
//  Created by Edgar Sia on 15/01/2020.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
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
            if SavorData.FireBase.isAuthenticated {
                self.newPost()
            } else {
                self.promptAuthentication()
            }
            
            return false
        }
        
        return true
    }
}

// MARK: - Authentication
extension TabBarController {
    
    func promptAuthentication() {
        let alertController = UIAlertController.init(title: "New Post", message: "You must be a registered user to access this feature.", preferredStyle: .alert)
        let signUp = UIAlertAction.init(title: "Sign Up", style: .default) { (action) in
            let viewController = CreateNewAccountViewController.instanceOnNavigationController {
                self.newPost()
            }
            self.present(viewController, animated: true, completion: nil)
        }
        let signIn = UIAlertAction.init(title: "Sign In", style: .default) { (action) in
            let viewController = SignInViewController.instanceOnNavigationController {
                self.newPost()
            }
            self.present(viewController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(signUp)
        alertController.addAction(signIn)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func newPost() {
        let viewController = NewPostViewController.instanceOnNavigationController {
            // notify feed view needs to display new post
            NotificationCenter.default.post(name: Notification.Name.init(NewPostViewController.postNotification), object: nil)
        }
        self.present(viewController, animated: true, completion: nil)
    }
}
