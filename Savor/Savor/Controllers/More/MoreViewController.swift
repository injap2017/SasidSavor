//
//  MoreViewController.swift
//  Savor
//
//  Created by Edgar Sia on 10/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import Firebase

class MoreViewController: UITableViewController {
    
    
    // MARK: - Properties
    private var handle: AuthStateDidChangeListenerHandle?
    
    deinit {
        // remove auth state change listener
        Auth.auth().removeStateDidChangeListener(self.handle!)
    }
}

// MARK: - Lifecycle
extension MoreViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        
        // listen auth state change to refresh
        self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.refreshView()
        }
    }
}

// MARK: - Functions
extension MoreViewController {
    
    func initView() {
        
        // cell
        self.tableView.register(ActionCell.nib, forCellReuseIdentifier: ActionCell.identifier)
    }
    
    func refreshView() {
        // bar button item
        self.navigationItem.rightBarButtonItem = SSUser.isAuthenticated ? self.signOutBarButtonItem() : nil
        
        // table view
        self.tableView.reloadData()
    }
}

// MARK: - Actions
extension MoreViewController {
    
    func signOutBarButtonItem() -> UIBarButtonItem {
        let item = UIBarButtonItem.init(title: "Sign Out", style: .plain, target: self, action: #selector(signOutAction))
        return item
    }
    
    @objc func signOutAction() {
        do {
            try Auth.auth().signOut()
            
            // refresh view will be called automatically by statedidchangelistner
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - TableView
extension MoreViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return SSUser.isAuthenticated ? 0 : 1
        case 1:
            return SSUser.isAuthenticated ? 0 : 1
        default:
            return SSUser.isAuthenticated ? 1 : 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell.init()
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "Sign In"
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
            cell.title = "Create New Account"
            cell.isEnabled = true
            return cell
        default:
            let cell = UITableViewCell.init()
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = "My Profile"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case 0:
            // sign in
            let viewController = SignInViewController.instance {
                // refresh view will be called automatically by statedidchangelistner
            }
            self.navigationController?.pushViewController(viewController)
            
        case 1:
            // create new account
            let viewController = CreateNewAccountViewController.instanceOnNavigationController {
                // refresh view will be called automatically by statedidchangelistner
            }
            self.present(viewController, animated: true, completion: nil)
            
        default:
            // my profile
            break
        }
    }
}
