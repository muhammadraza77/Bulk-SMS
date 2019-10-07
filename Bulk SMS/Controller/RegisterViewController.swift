//
//  RegisterViewController.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 10/4/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Firebase
class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func registerButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        Auth.auth().createUser(withEmail: emailTextView.text!, password: passwordTextView.text!) {
            (user, error) in
            if error != nil{
                SVProgressHUD.dismiss()
                print("error")
            }else{
                print("Sucessful")
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToMain", sender: self)

            }
        }
    }
}
