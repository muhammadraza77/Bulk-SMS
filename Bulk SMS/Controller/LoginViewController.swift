//
//  LoginViewController.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 10/4/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SVProgressHUD

class LoginViewController:UIViewController{
    
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "goToMain", sender: self)
        }
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        print(passwordTextView.text!)
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTextView.text!, password: passwordTextView.text!)
        { (user,error) in
            if error != nil{
                SVProgressHUD.dismiss()
                print("Error present")
            }else{
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
        }
        
    }
    
}
