//
//  ExpensesViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 27.11.2021.
//

import UIKit
import Firebase

class ExpensesViewController: UIViewController {
    
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var addExpenseButton: UIButton!
    
    var expenses: [Expense] = []
    var selectedExpense: Expense?
    var data: [String: Any]?
    
    // Input
    var groupCode: String?
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "ExpenseCell", bundle: nil), forCellReuseIdentifier: "expenseCell")
        
        tableView.rowHeight = 50.0
        
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
        
        db.collection("group")
            .whereField("code", isEqualTo: groupCode!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    let t = querySnapshot!.documents[0]
                    self.data = t.data()
                    
                    if((self.data!["autherizedUsers"] as! [String]) .contains(Auth.auth().currentUser!.email!)){
                        self.addExpenseButton.isEnabled = true
                    }
                    else{
                        self.addExpenseButton.isEnabled = false
                    }
                    
                }
            }
        
        
        db.collection("expense_" + groupCode!)
            .order(by: "date")
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.expenses.removeAll()
                    var tempAmount: Float = 0.0
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let expense = Expense(name: data["name"] as! String,
                                              amount: Float(String(format:"%.2f", data["amount"] as! Float))!,
                                              spender: data["spender"] as! String,
                                              type: ExpenseType(rawValue: (data["type"] as! String))!,
                                              date: data["date"] as! NSNumber)
                        tempAmount += expense.amount
                        self.expenses.append(expense)
                        
                    }
                    self.amountLabel.text = String(format:"%.2f", tempAmount)
                    self.tableView.reloadData()
                    
                    // Scroll to bottom of expenses
                    if(self.expenses.count >= 1){
                        let indexPath = IndexPath(row: self.expenses.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath , at: .top , animated: false)
                    }
                    
                }
            }
    }
    
    @IBAction func createExpenseClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "addExpense", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addExpense"){
            let obj = segue.destination as! AddExpenseViewController
            obj.groupCode = self.groupCode!
        }
        else if (segue.identifier == "expenseDetail"){
            let obj = segue.destination as! ExpenseDetailViewController
            obj.expense = selectedExpense
        }
    }
}

extension ExpensesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as! ExpenseCell
        cell.name.text = expenses[indexPath.row].name
        cell.amount.text = String(expenses[indexPath.row].amount)
        
        
        var localDate: String?
        if let timeResult = (expenses[indexPath.row].date as? Double) {
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            //dateFormatter.locale = = Locale.init(identifier: Locale.preferredLanguages.first!)
            dateFormatter.timeStyle = .none //Set time style
            dateFormatter.dateStyle = .medium //Set date style
            dateFormatter.timeZone = .current
            localDate = dateFormatter.string(from: date)
        }
        
        
        cell.date.text = localDate!
        
        return cell
    }
    
}


extension ExpensesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedExpense = expenses[indexPath.row]
        performSegue(withIdentifier: "expenseDetail", sender: self)
    }
}
