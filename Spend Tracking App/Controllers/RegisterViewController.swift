//
//  RegisterViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 25.11.2021.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var surnameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let db = Firestore.firestore()
    
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Loading indicator configuration
        indicator.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        indicator.center = view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
    }
    
    @IBAction func registerClicked(_ sender: UIButton) {
        
        
        if let email = emailField.text, let password = passwordField.text{
            indicator.startAnimating()
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    return
                }
                else{
                    var ref: DocumentReference? = nil
                    ref = self.db.collection("user").addDocument(data: [
                        "name": self.nameField.text!,
                        "phone": self.phoneField.text!,
                        "email": email,
                        "password": self.passwordField.text!,
                        "date":Date().timeIntervalSince1970
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(ref!.documentID)")
                            self.indicator.stopAnimating()
                            self.navigationController?.popViewController(animated: true);
                        }
                    }
                }
            }
        }
    }
}


