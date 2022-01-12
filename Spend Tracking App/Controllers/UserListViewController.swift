//
//  UserListViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 11.01.2022.
//

import UIKit
import Firebase

class UserListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var users = [[String]]()
    var selectedUser = [String]()
    
    let db = Firestore.firestore()
    
    // Input
    var data: [String: Any]?
    var groupCode: String?
    var isAll: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.rowHeight = 50.0
        
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.darkGray.cgColor
        tableView.layer.masksToBounds = true
        
        db.collection("group")
            .whereField("code", isEqualTo: groupCode!)
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let t = querySnapshot!.documents[0]
                    self.data = t.data()
                    
                    var userEmails: [String]?
                    
                    if(self.isAll! == true){
                        userEmails = (self.data!["users"] as! [String])
                    }
                    else{
                        userEmails = (self.data!["autherizedUsers"] as! [String])
                    }
                    
                    self.db.collection("user")
                        .whereField("email", in: userEmails!)
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                self.users.removeAll()
                                for document in querySnapshot!.documents {
                                    let data = document.data()
                                    self.users.append([data["email"] as! String, data["name"] as! String])
                                }
                            }
                            self.tableView.reloadData()
                        }
                }
            }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goMemberProfile"){
            let obj = segue.destination as! ProfileViewController
            obj.user = selectedUser[0]
        }
    }
    
}


extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        cell.userButton.setTitle(users[indexPath.row][1], for: .normal)
        cell.clickEvent = {
            self.selectedUser = self.users[indexPath.row]
            self.performSegue(withIdentifier: "goMemberProfile", sender: self)
        }
        cell.switchEvent = {
            self.db.collection("group")
                .whereField("code", isEqualTo: self.groupCode!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        let document = querySnapshot!.documents.first
                        var autherizedUsers: [String] = document!.data()["autherizedUsers"] as! [String]
                        
                        if(cell.autherizedSwitch.isOn == true){
                            autherizedUsers.append(self.users[indexPath.row][0])
                        }
                        else{
                            autherizedUsers.removeAll(where: { $0 == self.users[indexPath.row][0] })
                        }
                        document!.reference.updateData([
                            "autherizedUsers": autherizedUsers
                        ])
                    }
                }
        }
        
        if((data!["admin"] as! String) == Auth.auth().currentUser!.email){
            cell.autherizedSwitch.isEnabled = true
        }
        else{
            cell.autherizedSwitch.isEnabled = false
        }
        
        if((data!["autherizedUsers"] as! [String]).contains(users[indexPath.row][0]) || users[indexPath.row][0] == data!["admin"] as! String){
            cell.autherizedSwitch.isOn = true
        }
        else{
            cell.autherizedSwitch.isOn = false
        }
        
        if((data!["admin"] as! String) == users[indexPath.row][0]){
            cell.autherizedSwitch.isEnabled = false
        }
        
        return cell
    }
    
}
