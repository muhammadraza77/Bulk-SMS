//
//  ViewController.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 9/29/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import UIKit
import MessageUI
import FirebaseDatabase
import Contacts

class ViewController: UIViewController, MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    let messageVC = MFMessageComposeViewController()
    var reference:DatabaseReference!
    var numbersOnly:[String]=[String]()
    var contactData = [String]()

    var SelectedGroup:Group!{
        didSet{

            self.navigationItem.title=SelectedGroup.groupName

        }
    }
    
    var contactList:[Contact]=[Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing=false
        
        tableView.delegate=self
        tableView.dataSource=self
        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        tableView.rowHeight=70
        tableView.separatorStyle = .none
        
        messageTextField.delegate=self
        let tabGesture=UITapGestureRecognizer(target: self, action: #selector(tappedfunction))
        tableView.addGestureRecognizer(tabGesture)
        
        reference = Database.database().reference()
        loadContactInfo()
        


        
    }
    @objc func tappedfunction(){
        messageTextField.endEditing(true)
        
    }

    @IBAction func viewContactPressed(_ sender: Any) {
//        loadContacts()
//        loadContactInfo()
//        print("#####3")
//        print(contactList.first?.name)
        performSegue(withIdentifier: "viewContacts", sender: self)

    }
    @IBAction func addContactPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addContacts", sender: self)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageURL=info[UIImagePickerController.InfoKey.imageURL] {
            imagePicker.dismiss(animated: true) {

                self.messageVC.addAttachmentURL(imageURL as! URL, withAlternateFilename: nil)

            }
            
        }
    }
    
    @IBAction func addAttachmentButtonPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    @IBAction func sendButtonPresed(_ sender: Any) {
        messageVC.body = messageTextField.text;
        messageVC.recipients = numbersOnly
        messageVC.messageComposeDelegate = self

        self.present(messageVC, animated: true, completion: nil)
        messageTextField.endEditing(true)
    }
    func loadContactInfo(){
        let target=reference.child("groupInfo").child("user1").child(SelectedGroup.groupID)
        target.observe(.childAdded) { (DataSnapshot) in
            let snapshot=DataSnapshot.value as! Dictionary<String,String>
            let contact=Contact()
            contact.name=snapshot["name"]!
            contact.number=snapshot["number"]!
            self.numbersOnly.append(contact.number)
            self.contactList.append(contact)
        }
        
    }
//    func lloadContactInfo(){
//        let target=reference.child("groupInfo").child("user1").child(SelectedGroup.groupID)
//        target.observe(.childAdded) { (DataSnapshot) in
//            let snapshot=DataSnapshot.value as! Dictionary<String,String>
//            let contact=Contact()
//            contact.name=snapshot["name"]!
//            contact.number=snapshot["number"]!
//            self.numbersOnly.append(contact.number)
//            self.contactList.append(contact)
//        }
//
//    }
//    func loadContacts()  {
//        let store = CNContactStore()
//        store.requestAccess(for: .contacts) { (granted, err) in
//            if let whaterr = err{
//                print("Failed to open the App \(whaterr)")
//            }
//            if granted {
//                print("ACCESS GRANTED")
//                let keys = [CNContactGivenNameKey,CNContactPhoneNumbersKey]
//                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
//                do{
//                    try store.enumerateContacts(with: request
//                        , usingBlock: { (contact, stopPointerIfYouToStopEnumerating) in
//                            self.contactData.append(contact.givenName)
//                            print(contact.givenName)
//                            print(contact.phoneNumbers[0].value.stringValue)
//                    })
//                }catch{
//
//                }
//
//            }
//            else{
//                print("denied")
//            }
//        }
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="addContacts" {
            let destination = segue.destination as! ContactsViewController
            
            destination.SelectedGroup=self.SelectedGroup
            
        }else if segue.identifier=="viewContacts"{
            let destination = segue.destination as! ViewMemberViewController
            
            destination.contacts = contactList
            
        }
    }

}



extension ViewController: UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mycel = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath)
        
        return mycel
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant=310
            self.view.layoutIfNeeded()

        }
    }

    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant=50
            self.view.layoutIfNeeded()

        }
    }

    
    
}

