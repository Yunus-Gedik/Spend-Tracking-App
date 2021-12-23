//
//  GroupViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 27.11.2021.
//

import UIKit
import Firebase

class GroupViewController: UIViewController {
    
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var daysPassedLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    var expenses: [Expense] = []
    var groupCode: String?
    
    var titleInput: String?
    let db = Firestore.firestore()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let t = titleInput{
            self.title = t
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Wrapper Box of summary
        summaryView.layer.borderWidth = 1
        summaryView.layer.borderColor = UIColor.black.cgColor
        summaryView.layer.cornerRadius = 20
        summaryView.layer.masksToBounds = true;
        
        /*
         // Delete all documents of a collection
        db.collection("expense").addSnapshotListener() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.db.collection("expense").document("\(document.documentID)").delete()
                }
            }
        }
        */
        
        db.collection("expense")
            .order(by: "date")
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.expenses.removeAll()
                    var tempAmount: Float = 0.0
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if(data["group"] as! String == self.groupCode!){
                            let expense = Expense(name: data["name"] as! String,
                                                  amount: Float(String(format:"%.2f", data["amount"] as! Float))!,
                                                  spender: data["spender"] as! String,
                                                  type: ExpenseType(rawValue: (data["type"] as! String))!,
                                                  group: data["group"] as! String,
                                                  date: data["date"] as! NSNumber)
                            tempAmount += expense.amount
                            self.expenses.append(expense)
                        }
                    }
                    self.amountLabel.text = String(format:"%.2f", tempAmount)
                    self.reloadData()
                }
            }
    }
    
    func reloadData(){
        self.tableView.reloadData()
    }
}

extension GroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupTableProt", for: indexPath)
        cell.textLabel?.text = expenses[indexPath.row].name
        return cell
    }
    
}


extension GroupViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       //performSegue(withIdentifier: "addExpense", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addExpense"){
            let obj = segue.destination as! AddExpenseViewController
            obj.groupCode = groupCode
        }
    }
}
