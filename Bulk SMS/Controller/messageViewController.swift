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
import Firebase

class messageViewController: UIViewController, MFMessageComposeViewControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    var messageVC = MFMessageComposeViewController()
    var reference:DatabaseReference!
    var numbersOnly:[String]=[String]()
    var contactData = [String]()
    var messageData:[Message] = [Message]()
    var imageURLs:[String]=[String]()
    
    @IBOutlet weak var addAttachmentButton: UIButton!
    
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
        tableView.register(UINib(nibName: "MessageImgTableViewCell", bundle: nil), forCellReuseIdentifier: "imgMessage")

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        
        
        messageTextField.delegate=self
        let tabGesture=UITapGestureRecognizer(target: self, action: #selector(tappedfunction))
        tableView.addGestureRecognizer(tabGesture)

        // Register your Notification, To know When Key Board Appears.

        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillShow(notification:)),name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.keyboardWillHide(notification:)),name: UIResponder.keyboardWillHideNotification, object: nil)

        
        reference = Database.database().reference()
        loadContactInfo()
        loadMessages()
    

        
    }
    @objc func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant=keyboardHeight+keyboardHeight*0.20
            self.view.layoutIfNeeded()

        }


    }

    @objc func keyboardWillHide(notification:NSNotification) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant=50
            self.view.layoutIfNeeded()

        }

    }
    
    @objc func tappedfunction(){
        messageTextField.endEditing(true)
        
        

    }


    @IBAction func viewContactPressed(_ sender: Any) {

        performSegue(withIdentifier: "viewContacts", sender: self)

    }
    @IBAction func addContactPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addContacts", sender: self)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageURL=info[UIImagePickerController.InfoKey.imageURL] {
            imagePicker.dismiss(animated: true) {
                
                let path=(imageURL as AnyObject).absoluteString!.components(separatedBy: "//")[1]
                self.imageURLs.append(path)
                
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
                  var timestamp = String(NSDate().timeIntervalSince1970).components(separatedBy: ".")[0]
            var ans:Int!
            
            var dictionary:Dictionary<String,String> = [:]
            dictionary["text"]=messageTextField.text
            dictionary["img"]="nil"
            
            
            let target=self.reference.child("messages").child(self.SelectedGroup.groupID).child(timestamp)
            target.setValue(dictionary)
            ans=Int(timestamp)!+1
            timestamp=String(ans)
            
            for imgURL in self.imageURLs{
//                let timestamp1 = String(NSDate().timeIntervalSince1970).components(separatedBy: ".")[0]
                var dictionary1:Dictionary<String,String> = [:]
                dictionary1["text"]=messageTextField.text
                dictionary["img"]=imgURL
                
                
                let target=self.reference.child("messages").child(self.SelectedGroup.groupID).child(timestamp)
                target.setValue(dictionary)

                ans=Int(timestamp)!+1
                timestamp=String(ans)
            }

            messageVC = MFMessageComposeViewController()
            imageURLs.removeAll()
            messageTextField.text = ""
            
//            addAttachmentButton.buttonType = UIButton.ButtonType.contactAdd
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

        self.present(messageVC, animated: true,completion: nil)

        messageTextField.endEditing(true)
    }
    func loadContactInfo(){
        let target=reference.child("groupInfo").child(Auth.auth().currentUser!.uid).child(SelectedGroup.groupID)
        target.observe(.childAdded) { (DataSnapshot) in
            let snapshot=DataSnapshot.value as! Dictionary<String,String>
            let contact=Contact()
            contact.name=snapshot["name"]!
            contact.number=snapshot["number"]!
            contact.contactID = DataSnapshot.key
            self.numbersOnly.append(contact.number)
            self.contactList.append(contact)
        }
        target.observe(.childRemoved) { (DataSnapshot) in
            let snapshot=DataSnapshot.value as! Dictionary<String,String>
            let contact=Contact()
            contact.name=snapshot["name"]!
            contact.number=snapshot["number"]!
            contact.contactID = DataSnapshot.key
            
            self.contactList = self.contactList.filter( {$0 != contact} )
        }
        
    }
    func loadMessages(){
        let target=self.reference.child("messages").child(self.SelectedGroup.groupID)
        target.observe(.childAdded) { (DataSnapshot) in
            let snapshot=DataSnapshot.value as! Dictionary<String,String>
            let message:Message = Message()
            message.text = snapshot["text"]!
            message.img = snapshot["img"]!
            self.messageData.append(message)
            self.tableView.reloadData()
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="addContacts" {
            let destination = segue.destination as! ContactsViewController
            
            destination.SelectedGroup=self.SelectedGroup
            
        }else if segue.identifier=="viewContacts"{
            let destination = segue.destination as! ViewMemberViewController
            
            destination.contacts = contactList
            destination.group = self.SelectedGroup
            
        }
    }

}



extension messageViewController: UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messageData[indexPath.row]
        if msg.img == "nil" {
            let mycel = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
            mycel.Msgtext.text=messageData[indexPath.row].text
            return mycel
        }else{
            let mycel = tableView.dequeueReusableCell(withIdentifier: "imgMessage", for: indexPath) as! MessageImgTableViewCell
            
            if let img=UIImage(contentsOfFile: messageData[indexPath.row].img){
                mycel.imagemm.image = img
            
//                if FileManager.default.fileExists(atPath: imageURLs[indexPath.row]) {
//                    let url = NSURL(string: imageURLs[indexPath.row])
//                    let data = NSData(contentsOf: url! as URL)
//                    mycel.imagemm.image = UIImage(data: data! as Data)
//                }
            }
//
//            let url = URL(string:"https://cdn.pixabay.com/photo/2014/12/15/17/16/pier-569314__340.jpg")
//            mycel.imagemm.kf.setImage(with: url)
            return mycel
        }
        
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {

        UIView.animate(withDuration: 0.5){
//            self.heightConstraint.constant=390
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

