//
//  RequestCell.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 12.01.2022.
//

import UIKit

class RequestCell: UITableViewCell {

    @IBOutlet var userButton: UIButton!
    @IBOutlet var denyButton: UIButton!
    
    var userInfoEvent: (()->Void)? = nil
    var denyEvent: (()->Void)? = nil
    var approveEvent: (()->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        denyButton.tintColor = .systemRed
        
        // Selected bacground is transparent
        let bgColorView = UIView()
        bgColorView.backgroundColor =  .clear
        self.selectedBackgroundView = bgColorView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func userButtonClicked(_ sender: UIButton) {
        if let t = userInfoEvent{
            t()
        }
    }
    
    @IBAction func denyClicked(_ sender: UIButton) {
        if let t = denyEvent{
            t()
        }
    }
    
    @IBAction func approveClicked(_ sender: UIButton) {
        if let t = approveEvent{
            t()
        }
    }
    
}
