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
    
    // Input
    var groupCode: String?
    
    
    let db = Firestore.firestore()
    var currentSwitch: ExpenseType?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func foodSwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.food
        if(sender.isOn){
            otherSwitch.isOn = false
            luxurySwitch.isOn = false
            rentSwitch.isOn = false
            eventSwitch.isOn = false
        }
    }
    
    @IBAction func luxurySwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.luxury
        if(sender.isOn){
            foodSwitch.isOn = false
            otherSwitch.isOn = false
            rentSwitch.isOn = false
            eventSwitch.isOn = false
        }
    }
    
    @IBAction func rentSwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.rent
        if(sender.isOn){
            foodSwitch.isOn = false
            luxurySwitch.isOn = false
            otherSwitch.isOn = false
            eventSwitch.isOn = false
        }
    }
    
    @IBAction func eventSwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.event
        if(sender.isOn){
            foodSwitch.isOn = false
            luxurySwitch.isOn = false
            rentSwitch.isOn = false
            otherSwitch.isOn = false
        }
    }
    
    @IBAction func otherSwitchValueChanged(_ sender: UISwitch) {
        currentSwitch = ExpenseType.other
        if(sender.isOn){
            foodSwitch.isOn = false
            luxurySwitch.isOn = false
            rentSwitch.isOn = false
            eventSwitch.isOn = false
        }
    }
    
    @IBAction func addExpenseClicked(_ sender: UIButton) {
        if(expenseNameTextField.text != nil && amountTextField.text != nil){
            var ref: DocumentReference? = nil
            ref = db.collection("expense").addDocument(data: [
                "name": expenseNameTextField.text!,
                "amount": Float(String(format:"%.2f", Float(amountTextField.text!)!))!,
                "spender": Auth.auth().currentUser!.email! as String,
                "type": currentSwitch!.rawValue,
                "group": groupCode!,
                "date":Date().timeIntervalSince1970
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.navigationController?.popViewController(animated: true);
                }
            }
        }
    }
    
}
