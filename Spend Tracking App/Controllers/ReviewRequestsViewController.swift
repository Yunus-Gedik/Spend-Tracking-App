//
//  ReviewRequestsViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 11.01.2022.
//

import UIKit
import Firebase

class ReviewRequestsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var requests = [[String]]()
    var data: [String: Any]?
    var selectedUser = [String]()
    
    let db = Firestore.firestore()
    
    // Input
    var groupCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RequestCell", bundle: nil), forCellReuseIdentifier: "requestCell")
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
                    
                    let requestEmails = (self.data!["requests"] as! [String])
                    
                    if(requestEmails.count != 0){
                        self.db.collection("user")
                            .whereField("email", in: requestEmails)
                            .getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    self.requests.removeAll()
                                    for document in querySnapshot!.documents {
                                        let data = document.data()
                                        self.requests.append([data["email"] as! String, data["name"] as! String])
                                    }
                                    self.tableView.reloadData()
                                }
                            }
                    }
                    else{
                        self.requests.removeAll()
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goRequestProfile"){
            let obj = segue.destination as! ProfileViewController
            obj.user = selectedUser[0]
        }
    }
    
    
}

extension ReviewRequestsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as! RequestCell
        cell.userButton.setTitle(requests[indexPath.row][1], for: .normal)
        cell.userInfoEvent = {
            self.selectedUser = self.requests[indexPath.row]
            self.performSegue(withIdentifier: "goRequestProfile", sender: self)
        }
        
        cell.approveEvent = {
            self.db.collection("group")
                .whereField("code", isEqualTo: self.groupCode!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        let document = querySnapshot!.documents.first
                        
                        var users: [String] = document!.data()["users"] as! [String]
                        users.append(self.requests[indexPath.row][0])
                        
                        var requests: [String] = document!.data()["requests"] as! [String]
                        requests.removeAll(where: { $0 == self.requests[indexPath.row][0] })
                        
                        document!.reference.updateData([
                            "users": users,
                            "requests": requests
                        ])
                    }
                }
        }
        
        cell.denyEvent = {
            self.db.collection("group")
                .whereField("code", isEqualTo: self.groupCode!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        let document = querySnapshot!.documents.first
                        
                        var requests: [String] = document!.data()["requests"] as! [String]
                        requests.removeAll(where: { $0 == self.requests[indexPath.row][0] })
                        
                        document!.reference.updateData([
                            "requests": requests
                        ])
                    }
                }
        }
        
        
        return cell
    }
    
}
