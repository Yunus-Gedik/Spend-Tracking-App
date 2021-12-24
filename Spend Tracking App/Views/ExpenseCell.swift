//
//  ExpenseCell.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 24.12.2021.
//

import UIKit

class ExpenseCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var spender: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}