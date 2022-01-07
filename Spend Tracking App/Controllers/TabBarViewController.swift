//
//  TabBarViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 7.01.2022.
//

import UIKit

class TabBarViewController: UITabBarController {

    // Input
    var groupCode: String?
    var titleInput: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let t = titleInput{
            self.title = t
        }
        
        let tabs = self.viewControllers!
        
        let expensesTab = tabs[0] as! ExpensesViewController
        expensesTab.groupCode = groupCode
        
        let infoTab = tabs[1] as! GroupInfoViewController
        infoTab.groupCode = groupCode
        
    }
    
}
