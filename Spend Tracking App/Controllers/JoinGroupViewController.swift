//
//  JoinGroupViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 24.12.2021.
//

import UIKit

class JoinGroupViewController: UIViewController {

    @IBOutlet weak var groupCode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func joinGroupClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
