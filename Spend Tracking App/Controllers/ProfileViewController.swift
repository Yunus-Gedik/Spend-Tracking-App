//
//  ProfileViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 27.11.2021.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db.collection("user").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let user = querySnapshot!.documents[0]

                self.nameLabel.text = user.data()["name"] as? String
                self.phoneLabel.text = user.data()["phone"] as? String
                self.emailLabel.text = user.data()["email"] as? String
            }
        }
    }
    
    @IBAction func logOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}
