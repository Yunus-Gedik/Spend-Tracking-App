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
    
    var groups: [Group] = []
    var selectedGroup: Group?
    
    var indicator: Indicator!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator = Indicator(self.view)
        
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "GroupCell", bundle: nil), forCellReuseIdentifier: "groupCell")
        tableView.rowHeight = 60.0
        
        
        /*
        // Delete all documents of a collection
        db.collection("group").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.db.collection("group").document("\(document.documentID)").delete()
                }
            }
        }
         */
        
        
        db.collection("group").order(by: "date")
            .addSnapshotListener { (querySnapshot, err) in
                self.indicator.start()
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.groups.removeAll()
                    if(querySnapshot!.documents.count != 0){
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if((data["users"] as! Array<String>).contains((Auth.auth().currentUser?.email)! as String)){
                                let group = Group(code: data["code"] as! String,
                                                  admin: data["admin"] as! String,
                                                  name: data["name"] as! String,
                                                  description: data["description"] as! String,
                                                  joinByCode: data["joinByCode"] as! Bool,
                                                  users: data["users"] as! [String],
                                                  autherizedUsers: data["autherizedUsers"] as! [String],
                                                  requests: data["requests"] as! [String],
                                                  date: data["date"] as! NSNumber)
                                self.groups.append(group)
                            }
                        }
                        self.reloadData()
                    }
                }
                self.indicator.stop()
            }
    }
    
    @IBAction func profileClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showGroupDetail"){
            let obj = segue.destination as! TabBarViewController
            obj.groupCode = selectedGroup!.code
            obj.titleInput = selectedGroup!.name
        }
        else if(segue.identifier == "goProfile"){
            let obj = segue.destination as! ProfileViewController
            obj.user = Auth.auth().currentUser?.email
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
    
}
