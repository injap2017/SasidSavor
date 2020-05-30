//
//  MoreViewController.swift
//  Savor
//
//  Created by Edgar Sia on 10/12/2019.
//  Copyright © 2019 Edgar Sia. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MoreViewController: UITableViewController {
    
    // MARK: - Properties
    var cells: [[((UITableView) -> UITableViewCell, (UITableView) -> Void)]] = [] /*(return cell, didSelectAction)*/
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    deinit {
        removeObservers()
    }
}

// MARK: - Lifecycle
extension MoreViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initView()
        self.observe()
    }
}

// MARK: - Functions
extension MoreViewController {
    
    func initView() {
        
        // cell
        self.tableView.register(ActionCell.nib, forCellReuseIdentifier: ActionCell.identifier)
        
    }
    
    func observe() {
        // listen auth state to switch between signin createnewaccount / my profile
        self.handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if SSUser.isAuthenticated {
                // signout bar button item
                self.navigationItem.rightBarButtonItem = self.signOutBarButtonItem()
                
                // cells
                self.cells.removeAll()
                self.cells.append([(self.myProfileCell, self.didSelectMyProfile)])
                
                // table view
                self.tableView.reloadData()
            } else {
                // none bar item
                self.navigationItem.rightBarButtonItem = nil
                
                // cells
                self.cells.removeAll()
                self.cells.append([(self.signInCell, self.didSelectSignIn)])
                self.cells.append([(self.createNewAccountCell, self.didSelectCreateNewAccount)])
                
                // table view
                self.tableView.reloadData()
            }
        }
    }
    
    func removeObservers() {
        // remove auth state change listener
        Auth.auth().removeStateDidChangeListener(self.handle!)
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
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func didSelectSignIn(_ tableView: UITableView) {
        let viewController = SignInViewController.instance {
            
        }
        self.navigationController?.pushViewController(viewController)
    }
    
    func didSelectCreateNewAccount(_ tableView: UITableView) {
        let viewController = CreateNewAccountViewController.instanceOnNavigationController {
            
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    func didSelectMyProfile(_ tableView: UITableView) {
        
        SVProgressHUD.show(withStatus: "Loading...")
        
        ProfileViewController.syncData(userID: SSUser.authCurrentUser.uid) { (viewController) in
            SVProgressHUD.dismiss()
            
            self.navigationController?.pushViewController(viewController)
        }
    }
}

// MARK: - TableView
extension MoreViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.cells.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cells[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cells[indexPath.section][indexPath.row].0(tableView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.cells[indexPath.section][indexPath.row].1(tableView)
    }
    
    func signInCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Sign In"
        return cell
    }
    
    func createNewAccountCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.identifier) as! ActionCell
        cell.title = "Create New Account"
        cell.isEnabled = true
        return cell
    }
    
    func myProfileCell(_ tableView: UITableView) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "My Profile"
        return cell
    }
}
