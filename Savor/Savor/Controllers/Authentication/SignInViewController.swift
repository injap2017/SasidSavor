//
//  SignInViewController.swift
//  Savor
//
//  Created by Edgar Sia on 2/20/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class SignInViewController: UITableViewController {

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
    
    class func instance() -> SignInViewController {
        let storyboard = UIStoryboard.init(name: "Authentication", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "signIn") as! SignInViewController
        return viewController
    }
    
    class func instanceOnNavigationController() -> UINavigationController {
        let viewController = self.instance()
        viewController.navigationItem.leftBarButtonItem = viewController.cancelBarButtonItem()
        let navigationController = UINavigationController.init(rootViewController: viewController)
        return navigationController
    }
    
    func initView() {
        // title
        self.title = "Sign In"
    }
}

// MARK: - Actions
extension SignInViewController {
    
    func cancelBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelAction))
        return item
    }
    
    @objc func cancelAction() {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
}
