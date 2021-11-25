//
//  GroupsViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 25.11.2021.
//

import UIKit
import Firebase

class GroupsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true;
    }
    
    
    @IBAction func logoutClicked(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true);
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}
