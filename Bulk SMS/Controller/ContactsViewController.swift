//
//  ContactsViewController.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 10/2/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import UIKit
import Contacts
import FirebaseDatabase

class ContactsViewController: UIViewController {
    var contacts:[Contact]=[Contact]()
    var selectedContacts:[Int]=[Int]()
    var refernce:DatabaseReference!
    var SelectedGroup:Group!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        loadContacts()
        
        refernce=Database.database().reference()
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func AddContact(_ sender: UIButton) {
//        var temp:Dictionary<String,String>!
        if selectedContacts.count>0{
            for n in 0...selectedContacts.count-1 {
                let index=selectedContacts[n]
                _=refernce.child("groupInfo").child("user1").child(SelectedGroup.groupID).childByAutoId().setValue(["name":contacts[index].name,"number":contacts[index].number])
            }

        }
        self.navigationController?.popViewController(animated: true)

    }
    
    func loadContacts()  {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if let whaterr = err{
                print("Failed to open the App \(whaterr)")
            }
            if granted {
                print("ACCESS GRANTED")
                let keys = [CNContactGivenNameKey,CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do{
                    try store.enumerateContacts(with: request
                        , usingBlock: { (contact, stopPointerIfYouToStopEnumerating) in
                            let temp:Contact=Contact()
                            temp.name=contact.givenName
                            temp.number=contact.phoneNumbers[0].value.stringValue
                            self.contacts.append(temp)
                    })
                }catch{
                    
                }
                self.tableView.reloadData()
                
            }
            else{
                print("denied")
            }
        }
    }
}
extension ContactsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mycell=tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        mycell.textLabel?.text = contacts[indexPath.row].name
        mycell.detailTextLabel?.text=contacts[indexPath.row].number
        return mycell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell=tableView.cellForRow(at: indexPath)
        
        if(cell?.accessoryType == UITableViewCell.AccessoryType.none){
            selectedContacts.append(indexPath.row)
            cell?.accessoryType = .checkmark
        }else{
            let index=selectedContacts.firstIndex(of: indexPath.row)
            selectedContacts.remove(at: index!)
            cell?.accessoryType = .none
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
