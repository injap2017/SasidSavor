//
//  CreateNewAccountViewController.swift
//  Savor
//
//  Created by Edgar Sia on 2/20/20.
//  Copyright © 2020 Edgar Sia. All rights reserved.
//

import UIKit

class CreateNewAccountViewController: UITableViewController {

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
    
    class func instance() -> CreateNewAccountViewController {
        let storyboard = UIStoryboard.init(name: "Authentication", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "createNewAccount") as! CreateNewAccountViewController
        return viewController
    }
    
    class func instanceOnNavigationController() -> UINavigationController {
        let viewController = self.instance()
        viewController.navigationItem.leftBarButtonItem = viewController.cancelBarButtonItem()
        let navigationController = UINavigationController.init(rootViewController: viewController)
        return navigationController
    }
    
    func initView() {
        // bar button item
        self.navigationItem.rightBarButtonItem = self.doneBarButtonItem()
        
        // title
        self.title = "Create New Account"
    }
}

// MARK: - Actions
extension CreateNewAccountViewController {
    
    func cancelBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelAction))
        return item
    }
    
    @objc func cancelAction() {
        self.navigationController?.dismiss(animated: true, completion: {
            
        })
    }
    
    func doneBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.doneAction))
        item.isEnabled = false
        return item
    }
    
    @objc func doneAction() {
        
    }
}
