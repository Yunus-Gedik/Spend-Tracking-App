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
    @IBOutlet var groupDescLabel: UILabel!
    
    @IBOutlet var createReportButton: UIButton!
    @IBOutlet var reviewJoinRequestsButton: UIButton!

    var adminEmail: String?
    var autherizedUsers = [String]()
    var allUsers = [String]()
    
    var allClicked: Bool?
    
    let db = Firestore.firestore()

    // Input
    var groupCode: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.collection("group")
            .order(by: "date")
            .whereField("code", isEqualTo: groupCode!)
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    let t = querySnapshot!.documents[0]
                    let data = t.data()
                    
                    self.autherizedUsers = data["autherizedUsers"] as! [String]
                    self.allUsers = data["users"] as! [String]
                    
                    self.groupNameLabel.text =  data["name"] as? String
                    self.codeLabel.text = data["code"] as? String
                    self.adminEmail = data["admin"] as? String
                    self.groupDescLabel.text = data["description"] as? String
                    
                    if(self.adminEmail! != Auth.auth().currentUser?.email!){
                        self.createReportButton.isHidden = true
                        self.reviewJoinRequestsButton.isHidden = true
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
    
    @IBAction func adminClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showAdminInfo", sender: self)
    }
    
    @IBAction func reviewRequestsClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goReviewRequests", sender: self)
    }
    
    @IBAction func createReportClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goReport", sender: self)
    }
    
    @IBAction func allUsersClicked(_ sender: UIButton) {
        allClicked = true
        performSegue(withIdentifier: "goUserList", sender: self)
    }
    
    @IBAction func autherizedUsers(_ sender: UIButton) {
        allClicked = false
        performSegue(withIdentifier: "goUserList", sender: self)
    }
    
    @IBAction func lastReportClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goReport", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showAdminInfo"){
            let obj = segue.destination as! ProfileViewController
            obj.user = adminEmail!
        }
        else if(segue.identifier == "goReviewRequests"){
            let obj = segue.destination as! ReviewRequestsViewController
            //obj.groupCode = groupCode!
        }
        else if(segue.identifier == "goReport"){
            let obj = segue.destination as! ReportViewController
            //obj.groupCode = groupCode!
        }
        else if(segue.identifier == "goUserList"){
            let obj = segue.destination as! UserListViewController
            if(allClicked!){
                obj.userEmails = allUsers
            }
            else{
                obj.userEmails = autherizedUsers
            }
            
        }
    }
    
}
