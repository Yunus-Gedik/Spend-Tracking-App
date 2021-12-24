//
//  GroupsViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 25.11.2021.
//

import UIKit
import Firebase

class GroupsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var groups: [Group] = []
    var selectedGroup: Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "groupCell")
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        tableView.rowHeight = 60.0
        
        db.collection("group").order(by: "date")
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.groups.removeAll()
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if((data["users"] as! Array<String>).contains((Auth.auth().currentUser?.email)! as String)){
                            let group = Group(code: data["code"] as! String,
                                              admin: data["admin"] as! String,
                                              name: data["name"] as! String,
                                              description: data["description"] as! String,
                                              period: data["period"] as! Int,
                                              users: data["users"] as! [String],
                                              autherizedUsers: data["autherizedUsers"] as! [String],
                                              date: data["date"] as! NSNumber)
                            self.groups.append(group)
                        }
                    }
                    self.reloadData()
                }
            }
    }
    
    @IBAction func profileClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goProfile", sender: self)
    }
    
    @IBAction func createGroupClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "createGroup", sender: self)
    }
    
    @IBAction func createPersonalBalanceSheetClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "popUp", sender: self)
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    
    
    func reloadData(){
        self.tableView.reloadData()
    }
}


extension GroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupCell
        cell.name.text = groups[indexPath.row].name
        return cell
    }
    
}


extension GroupsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedGroup = groups[indexPath.row]
        performSegue(withIdentifier: "showGroupDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showGroupDetail"){
            let obj = segue.destination as! GroupViewController
            obj.groupCode = selectedGroup!.code
            obj.title = selectedGroup!.name
        }
    }
}
