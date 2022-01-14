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
    @IBOutlet var joinByCodeSwitch: UISwitch!
    
    @IBOutlet var createReportButton: UIButton!
    @IBOutlet var reviewJoinRequestsButton: UIButton!
    
    var adminEmail: String?
    var allClicked: Bool?
    
    let db = Firestore.firestore()
    
    // Input
    var groupCode: String?
    
    
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
                    
                    self.groupNameLabel.text =  data["name"] as? String
                    self.codeLabel.text = data["code"] as? String
                    self.adminEmail = data["admin"] as? String
                    self.groupDescLabel.text = data["description"] as? String
                    self.joinByCodeSwitch.isOn = data["joinByCode"] as! Bool
                    
                    if(self.adminEmail! != Auth.auth().currentUser?.email!){
                        self.createReportButton.isHidden = true
                        self.reviewJoinRequestsButton.isHidden = true
                        self.joinByCodeSwitch.isEnabled = false
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
                }
            }
    }
    
    @IBAction func adminClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showAdminInfo", sender: self)
    }
    
    @IBAction func reviewRequestsClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goReviewRequests", sender: self)
    }
    
    @IBAction func createReportClicked(_ sender: UIButton){
        Task{
            do{
                let ss = try await db.collection("expense_" + groupCode!).getDocuments()
                if(ss.documents.count != 0){
                    // Delete all expenses of the previous report
                    do{
                        let oldReport = try await self.db.collection("expense_report_" + self.groupCode!).getDocuments()
                        if(oldReport.documents.count != 0){
                            for doc in oldReport.documents{
                                try await self.db.collection("expense_report_" + self.groupCode!).document("\(doc.documentID)").delete()
                            }
                        }
                    }catch{
                        print("DELETE PREVIOUS REPORT COLLECTION ERRRRRRRRRRRRRRROOOOOOOOOORRRR")
                    }
                    
                    for document in ss.documents{
                        let data = document.data()
                        
                        // Insert new report spents to report collection
                        self.db.collection("expense_report_" + self.groupCode!).addDocument(data: [
                            "name": data["name"]!,
                            "amount": data["amount"]!,
                            "spender": data["spender"]!,
                            "type": data["type"]!,
                            "date": data["date"]!
                        ])
                        
                        // Delete expense from current expenses
                        do{
                            try await self.db.collection("expense_" + self.groupCode!).document("\(document.documentID)").delete()
                        }catch{
                            print("DELETE EXPENSE FROM CURRENT EXPENSES ERRRRRRRRRRRRRRROOOOOOOOOORRRR")
                        }
                    }
                }
                
                
            }catch{
                print("CREATE REPORT BAŞTAN KOKAR ERROR")
            }
            performSegue(withIdentifier: "goReport", sender: self)
        } 
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
    
    @IBAction func joinByCodeSwitchChanged(_ sender: UISwitch) {
        self.db.collection("group")
            .whereField("code", isEqualTo: self.groupCode!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let document = querySnapshot!.documents.first
                    var joinByCode: Bool = document!.data()["joinByCode"] as! Bool
                    
                    if(self.joinByCodeSwitch.isOn == true){
                        joinByCode = true
                    }
                    else{
                        joinByCode = false
                    }
                    document!.reference.updateData([
                        "joinByCode": joinByCode
                    ])
                }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showAdminInfo"){
            let obj = segue.destination as! ProfileViewController
            obj.user = adminEmail!
        }
        else if(segue.identifier == "goReviewRequests"){
            let obj = segue.destination as! ReviewRequestsViewController
            obj.groupCode = groupCode!
        }
        else if(segue.identifier == "goReport"){
            let obj = segue.destination as! ReportViewController
            obj.groupCode = groupCode!
        }
        else if(segue.identifier == "goUserList"){
            let obj = segue.destination as! UserListViewController
            obj.isAll = allClicked
            obj.groupCode = groupCode!
        }
    }
    
}
