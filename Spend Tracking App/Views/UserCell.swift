//
//  UserCell.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 11.01.2022.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet var userButton: UIButton!
    
    // Input
    var clickEvent: (()->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColorView = UIView()
        bgColorView.backgroundColor =  .clear
        self.selectedBackgroundView = bgColorView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func userButtonClicked(_ sender: UIButton) {
        if let t = clickEvent{
            t()
        }
    }
    
}
