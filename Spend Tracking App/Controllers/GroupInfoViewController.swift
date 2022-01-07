//
//  GroupInfoViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 7.01.2022.
//

import UIKit
import Firebase

class GroupInfoViewController: UIViewController {
    
    @IBOutlet var groupNameLabel: UILabel!
    @IBOutlet var codeLabel: UILabel!
    @IBOutlet var adminButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet var createReportButton: UIButton!
    @IBOutlet var lastReportButton: UIButton!
    
    // Input
    var groupCode: String?
    
    let db = Firestore.firestore()
    
    var adminEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.collection("group")
            .whereField("code", isEqualTo: groupCode!)
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    let t = querySnapshot!.documents[0]
                    let data = t.data()
                    
                    self.groupNameLabel.text =  data["name"] as? String
                    self.codeLabel.text = data["code"] as? String
                    self.adminEmail = data["admin"] as? String
                    
                    if(self.adminEmail! != Auth.auth().currentUser?.email!){
                        self.createReportButton.isHidden = true
                        self.lastReportButton.isHidden = true
                    }
                    
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
                    
                    self.db.collection("user")
                        .whereField("email", isEqualTo: data["admin"]!)
                        .addSnapshotListener { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                let t = querySnapshot!.documents[0]
                                let data = t.data()
                                self.adminButton.setTitle((data["name"] as! String), for: .normal)
                            }
                        }
                }
            }
    }
    
    
    @IBAction func createReportClicked(_ sender: UIButton) {
    }
    
    @IBAction func lastReportClicked(_ sender: UIButton) {
    }
    
    @IBAction func adminClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showAdminInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showAdminInfo"){
            let obj = segue.destination as! ProfileViewController
            obj.user = adminEmail!
        }
    }
    
}
