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
    var userEmails: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "userCell")
        tableView.rowHeight = 60.0
        
        db.collection("user")
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
            self.performSegue(withIdentifier: "goMemberProfile", sender: self)}
        return cell
    }
    
}

extension UserListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUser = users[indexPath.row]
        performSegue(withIdentifier: "goMemberProfile", sender: self)
    }
}
