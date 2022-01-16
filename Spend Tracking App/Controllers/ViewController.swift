//
//  ViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 25.11.2021.
//

import UIKit
import Firebase

class ViewController: UIViewController{
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var indicator: Indicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = Indicator(self.view)
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        
        if let email = emailField.text, let password = passwordField.text{
            indicator.start()
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
                if let e = error {
                    print(e.localizedDescription);
                }
                else{
                    self.performSegue(withIdentifier: "loginSuccess", sender: self)
                }
                self.indicator.stop()
            }
        }
    }
    
    @IBAction func emailDone(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func passwordDone(_ sender: UITextField) {
        sender.resignFirstResponder()
        loginClicked(UIButton())
    }
    
    @IBAction func forgotPasswordClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "forgotPassword", sender: self)
    }
    
    
    @IBAction func createAccountClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "register", sender: self)
    }
    
    
}

