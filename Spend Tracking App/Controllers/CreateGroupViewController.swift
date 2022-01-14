//
//  CreateGroupViewController.swift
//  Spend Tracking App
//
//  Created by Yunus Gedik on 27.11.2021.
//

import UIKit
import Firebase

class CreateGroupViewController: UIViewController {
    
    @IBOutlet weak var invitationCode: UILabel!
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var byCodeSwitch: UISwitch!
    @IBOutlet weak var byCodeLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Be sure group code is unique
        Task{
            let code = randomString(length: 6)
            while(invitationCode.text == "label"){
                let doc = try await db.collection("group").whereField("code", isEqualTo: code).getDocuments()
                if(doc.documents.count == 0){
                    self.invitationCode.text = code
                }
            }
        }
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
                "joinByCode": byCodeSwitch.isOn,
                "admin": Auth.auth().currentUser!.email! as String,
                "autherizedUsers": [(Auth.auth().currentUser?.email)! as String],
                "users": [(Auth.auth().currentUser?.email)! as String],
                "requests":[String].init(),
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
}
