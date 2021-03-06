//
//  UserCell.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 11.01.2022.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet var userButton: UIButton!
    @IBOutlet var autherizedSwitch: UISwitch!
    
    // Input
    var clickEvent: (()->Void)? = nil
    var switchEvent: (()->Void)? = nil
    
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
    
    @IBAction func userButtonClicked(_ sender: UIButton) {
        if let t = clickEvent{
            t()
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if let t = switchEvent{
            t()
        }
    }
}
