//
//  CreateGroupViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 27.11.2021.
//

import UIKit
import Firebase

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var period: UILabel!
    @IBOutlet weak var invitationCode: UILabel!
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var periodDays: Int = 7
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invitationCode.text = randomString(length: 6)
    }

    func randomString(length: Int) -> String {
        let letters = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func createGroupClicked(_ sender: UIButton) {
        
        if(groupName.text != nil){
            var ref: DocumentReference? = nil
            ref = db.collection("group").addDocument(data: [
                "name": groupName.text!,
                "description": descriptionTextField.text!,
                "code": invitationCode.text!,
                "period": periodDays,
                "admin": Auth.auth().currentUser!.email! as String,
                "autherizedUsers": [String].init(),
                "users": [(Auth.auth().currentUser?.email)! as String],
                "date":Date().timeIntervalSince1970
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.navigationController?.popViewController(animated: true);
                }
            }
        }
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        period.text = String(Int(sender.value)) + " Days"
        periodDays = Int(sender.value)
    }
    
}