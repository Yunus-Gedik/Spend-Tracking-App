//
//  SpentCell.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 13.01.2022.
//

import UIKit

class SpentCell: UITableViewCell {

    @IBOutlet var userButton: UIButton!
    @IBOutlet var amountLabel: UILabel!
    
    // Input
    var userInfoEvent: (()->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Selected bacground is transparent
        let bgColorView = UIView()
        bgColorView.backgroundColor =  .clear
        self.selectedBackgroundView = bgColorView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func userClicked(_ sender: UIButton) {
        if let t = userInfoEvent{
            t()
        }
    }
    
}
