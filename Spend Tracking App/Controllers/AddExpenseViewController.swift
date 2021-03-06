//
//  AddExpenseViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 22.12.2021.
//

import UIKit
import Firebase

class AddExpenseViewController: UIViewController {
    
    @IBOutlet weak var expenseNameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var foodSwitch: UISwitch!
    @IBOutlet weak var luxurySwitch: UISwitch!
    @IBOutlet weak var rentSwitch: UISwitch!
    @IBOutlet weak var eventSwitch: UISwitch!
    @IBOutlet weak var otherSwitch: UISwitch!
    
    @IBOutlet var bottomButton: UIButton!
    
    // Input
    var groupCode: String?
    
    // Edit Mode Input
    var expense: Expense?
    
    var indicator: Indicator!
    
    let db = Firestore.firestore()
    var currentSwitch: ExpenseType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = Indicator(self.view)
        
        if(expense != nil){
            bottomButton.setTitle("Update Expense", for: .normal)
            expenseNameTextField.text = expense!.name
            amountTextField.text = String(expense!.amount)
            switch expense!.type {
                case .food:
                    self.foodSwitch.isOn = true
                    self.currentSwitch = .food
                case .luxury:
                    self.luxurySwitch.isOn = true
                    self.currentSwitch = .luxury
                case .rent:
                    self.rentSwitch.isOn = true
                    self.currentSwitch = .rent
                case .event:
                    self.eventSwitch.isOn = true
                    self.currentSwitch = .event
                case .other:
                    self.otherSwitch.isOn = true
                    self.currentSwitch = .other
            }
        }
        
    }
    
    @IBAction func foodSwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.food
        if(sender.isOn){
            otherSwitch.setOn(false, animated: true)
            luxurySwitch.setOn(false, animated: true)
            rentSwitch.setOn(false, animated: true)
            eventSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func luxurySwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.luxury
        if(sender.isOn){
            foodSwitch.setOn(false, animated: true)
            otherSwitch.setOn(false, animated: true)
            rentSwitch.setOn(false, animated: true)
            eventSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func rentSwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.rent
        if(sender.isOn){
            foodSwitch.setOn(false, animated: true)
            luxurySwitch.setOn(false, animated: true)
            otherSwitch.setOn(false, animated: true)
            eventSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func eventSwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.event
        if(sender.isOn){
            foodSwitch.setOn(false, animated: true)
            luxurySwitch.setOn(false, animated: true)
            rentSwitch.setOn(false, animated: true)
            otherSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func otherSwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.other
        if(sender.isOn){
            foodSwitch.setOn(false, animated: true)
            luxurySwitch.setOn(false, animated: true)
            rentSwitch.setOn(false, animated: true)
            eventSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func addExpenseClicked(_ sender: UIButton) {
        if(expenseNameTextField.text != nil && amountTextField.text != nil){
            if(expense != nil){
                indicator.start()
                self.db.collection("expense_" + groupCode!)
                    .whereField("date", isEqualTo: self.expense!.date)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                            self.indicator.stop()
                        } else {
                            let document = querySnapshot!.documents.first
                        
                            document!.reference.updateData([
                                "name": self.expenseNameTextField.text!,
                                "amount": Float(String(format:"%.2f", self.amountTextField.text!.doubleValue))!,
                                "spender": Auth.auth().currentUser!.email! as String,
                                "type": self.currentSwitch!.rawValue,
                                "date":Date().timeIntervalSince1970
                            ])
                            self.indicator.stop()
                            self.navigationController?.popViewController(animated: true);
                        }
                    }
            }
            else{
                var ref: DocumentReference? = nil
                
                indicator.start()
                ref = db.collection("expense_" + groupCode!).addDocument(data: [
                    "name": expenseNameTextField.text!,
                    "amount": Float(String(format:"%.2f", amountTextField.text!.doubleValue))!,
                    "spender": Auth.auth().currentUser!.email! as String,
                    "type": currentSwitch!.rawValue,
                    "date":Date().timeIntervalSince1970
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        self.indicator.stop()
                    } else {
                        print("Document added with ID: \(ref!.documentID)")
                        self.indicator.stop()
                        self.navigationController?.popViewController(animated: true);
                    }
                }
            }
            
            
            
        }
    }
    
}

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}
