//
//  ExpenseDetailViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 5.01.2022.
//

import UIKit

class ExpenseDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet var spenderButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    // Input
    var expense: Expense?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = expense!.name
        
        nameLabel.text = expense!.name
        typeLabel.text = expense!.type.rawValue
        amountLabel.text = String(expense!.amount)
        spenderButton.titleLabel?.text = expense!.spender
        
        var localDate: String?
        if let timeResult = (expense!.date as? Double) {
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .none //Set time style
            dateFormatter.dateStyle = .full //Set date style
            dateFormatter.timeZone = .current
            localDate = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "HH:mm"
            localDate?.append(" " + dateFormatter.string(from: date))
        }
        dateLabel.text = localDate
    }

    @IBAction func spenderClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goProfileFromExpense", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goProfileFromExpense"){
            let obj = segue.destination as! ProfileViewController
            obj.user = expense!.spender
        }
    }
    
}
