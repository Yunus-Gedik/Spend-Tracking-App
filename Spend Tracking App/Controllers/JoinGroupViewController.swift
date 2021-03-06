//
//  JoinGroupViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 24.12.2021.
//

import UIKit
import Firebase

class JoinGroupViewController: UIViewController {
    
    @IBOutlet weak var groupCode: UITextField!
    
    var indicator: Indicator!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = Indicator(self.view)
        
        title = "Join a Group"
        
    }
    
    @IBAction func joinGroupClicked(_ sender: UIButton) {
        self.indicator.start()
        db.collection("group")
            .whereField("code", isEqualTo: groupCode.text!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.indicator.stop()
                } else if querySnapshot!.documents.count != 1 {
                    print("SAME CODE FOR MORE THAN ONE GROUP!!!")
                    self.indicator.stop()
                } else {
                    let document = querySnapshot!.documents.first
                    let data = document!.data()
                    
                    // Directly Add User
                    if(data["joinByCode"] as! Bool == true){
                        var users: [String] = document!.data()["users"] as! [String]
                        users.append(Auth.auth().currentUser!.email!)
                        document!.reference.updateData([
                            "users": users
                        ])
                    }
                    // Add User to Request List
                    else{
                        var requests: [String] = document!.data()["requests"] as! [String]
                        requests.append(Auth.auth().currentUser!.email!)
                        document!.reference.updateData([
                            "requests": requests
                        ])
                    }
                    self.indicator.stop()
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
    
}
