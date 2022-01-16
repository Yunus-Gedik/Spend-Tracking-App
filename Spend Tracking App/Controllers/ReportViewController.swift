//
//  ReportViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 11.01.2022.
//

import UIKit
import Firebase

class ReportViewController: UIViewController {

    @IBOutlet var expensesTableView: UITableView!
    @IBOutlet var spentTableView: UITableView!
    @IBOutlet var totalAmountLabel: UILabel!
    @IBOutlet var perCapitaLabel: UILabel!
    
    @IBOutlet var expensesHeightConstraint: NSLayoutConstraint!
    @IBOutlet var spentsHeightConstraint: NSLayoutConstraint!
    
    var selectedUser = [String]()
    var selectedExpense: Expense?
    
    var expenses: [Expense] = []
    var spents = [[String]]()
    
    
    let db =  Firestore.firestore()
    
    // Input
    var groupCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        expensesTableView.register(UINib(nibName: "ExpenseCell", bundle: nil), forCellReuseIdentifier: "expenseCell")
        expensesTableView.rowHeight = 50.0
        expensesTableView.dataSource = self
        expensesTableView.delegate = self
        
        
        spentTableView.register(UINib(nibName: "SpentCell", bundle: nil), forCellReuseIdentifier: "spentCell")
        spentTableView.rowHeight = 55.0
        spentTableView.dataSource = self
        
        Task{
            do{
                let report = try await self.db.collection("expense_report_" + self.groupCode!).getDocuments()
                if(report.documents.count != 0){
                    self.expenses.removeAll()
                    var tempAmount: Float = 0.0
                    for doc in report.documents{
                        let data = doc.data()
                        let expense = Expense(name: data["name"] as! String,
                                              amount: Float(String(format:"%.2f", data["amount"] as! Float))!,
                                              spender: data["spender"] as! String,
                                              type: ExpenseType(rawValue: (data["type"] as! String))!,
                                              date: data["date"] as! NSNumber)
                        tempAmount += expense.amount
                        self.expenses.append(expense)

                        if let index = self.spents.getColumn(column: 0).firstIndex(where: { $0 == data["spender"] as! String }) {
                            self.spents[index][2] = String(Float(self.spents[index][2])! + Float(String(format:"%.2f", data["amount"] as! Float))!)
                        }
                        
                        else{
                            var name = String()
                            let the_user = try await self.db.collection("user").whereField("email", isEqualTo: (data["spender"] as! String)).getDocuments()
                            
                            if(the_user.count != 0){
                                let t_doc = the_user.documents[0]
                                let t_doc_data = t_doc.data()
                                name = t_doc_data["name"] as! String
                            }
                                
                            self.spents.append([data["spender"] as! String, name, String(format:"%.2f", data["amount"] as! Float)])
                        }
                        
                    }
                    totalAmountLabel.text = String(tempAmount)
                    spentTableView.reloadData()
                    expensesTableView.reloadData()
                    
                    let the_user = try await self.db.collection("group").whereField("code", isEqualTo: self.groupCode!).getDocuments()
                    if(the_user.count != 0){
                        let t_doc = the_user.documents[0]
                        let t_doc_data = t_doc.data()
                        let group_users = t_doc_data["users"] as! [String]
                        perCapitaLabel.text = String(format:"%.2f", tempAmount / Float(group_users.count))
                    }
                }
            }catch{
                print("REPORT VIEW ERRRRRRRRRRRRRRROOOOOOOOOORRRR")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "reportToProfile"){
            let obj = segue.destination as! ProfileViewController
            obj.user = selectedUser[0]
        }
        else if (segue.identifier == "reportToExpense"){
            let obj = segue.destination as! ExpenseDetailViewController
            obj.expense = selectedExpense
        }
    }
    
}

extension ReportViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == expensesTableView){
            expensesHeightConstraint.constant = CGFloat(50 * expenses.count)
            return expenses.count
        }
        else{
            spentsHeightConstraint.constant = CGFloat(60 * spents.count)
            return spents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == expensesTableView){
            let cell = expensesTableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as! ExpenseCell
            cell.name.text = expenses[indexPath.row].name
            cell.amount.text = String(expenses[indexPath.row].amount)
            
            var localDate: String?
            if let timeResult = (expenses[indexPath.row].date as? Double) {
                let date = Date(timeIntervalSince1970: timeResult)
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .none //Set time style
                dateFormatter.dateStyle = .medium //Set date style
                dateFormatter.timeZone = .current
                localDate = dateFormatter.string(from: date)
            }

            cell.date.text = localDate!
            
            return cell
        }
        
        else{
            let cell = spentTableView.dequeueReusableCell(withIdentifier: "spentCell", for: indexPath) as! SpentCell
            cell.userInfoEvent = {
                self.selectedUser = self.spents[indexPath.row]
                self.performSegue(withIdentifier: "reportToProfile", sender: self)
            }
            cell.userButton.setTitle(self.spents[indexPath.row][1], for: .normal)
            cell.amountLabel.text = self.spents[indexPath.row][2]
            return cell
        }
    }
}


extension ReportViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == expensesTableView){
            self.selectedExpense = expenses[indexPath.row]
            performSegue(withIdentifier: "reportToExpense", sender: self)
        }
    }
}

// Get column of multidimensional array
extension Array where Element : Collection {
    func getColumn(column : Element.Index) -> [ Element.Iterator.Element ] {
        return self.map { $0[ column ] }
    }
}
