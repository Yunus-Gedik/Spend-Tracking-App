//
//  ProfileViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 27.11.2021.
//

import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Input
    var user: String?
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Logout button visibility
        let email = Auth.auth().currentUser?.email?.description
        if(!self.user!.isEqual(email)){
            self.navigationItem.rightBarButtonItem = nil
        }
        
        db.collection("user")
            .whereField("email", isEqualTo: user!)
            .addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {

                let t = querySnapshot!.documents[0]
                let data = t.data()
                
                self.nameLabel.text =  data["name"] as? String
                self.phoneLabel.text = data["phone"] as? String
                self.emailLabel.text = data["email"] as? String
                
                var localDate: String?
                if let timeResult = (data["date"] as? Double) {
                    let date = Date(timeIntervalSince1970: timeResult)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .none //Set time style
                    dateFormatter.dateStyle = .full //Set date style
                    dateFormatter.timeZone = .current
                    localDate = dateFormatter.string(from: date)
                    
                    dateFormatter.dateFormat = "HH:mm"
                    localDate?.append(" " + dateFormatter.string(from: date))
                }
                
                self.dateLabel.text = localDate!
                
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
