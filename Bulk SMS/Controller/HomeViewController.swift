//
//  HomeViewController.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 9/30/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwipeCellKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    
    var data:[Group]=[Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        tableView.delegate=self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "Home_GroupInfoCell", bundle: nil), forCellReuseIdentifier: "Home_GroupInfoCell")
        tableView.separatorStyle = .none
        tableView.rowHeight=57
        
        self.navigationItem.setHidesBackButton(true, animated:false)
        LoadData()
        // Do any additional setup after loading the view.
    }

    @IBAction func logout(_ sender: Any) {
        let alert=UIAlertController(title: "Logout", message: "Your are about to get Logout?Are You sure ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (UIAlertAction) in
            do{
                try Auth.auth().signOut()
                self.navigationController?.popToRootViewController(animated: true)
            }catch{
                
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    @IBAction func addNewGroup(_ sender: UIBarButtonItem) {
        let target=ref.child("groupIDs").child(Auth.auth().currentUser!.uid)

        var nametextField:UITextField!
        var desctextField:UITextField!
        
        let alert=UIAlertController(title: "Add New Group", message: "", preferredStyle: .alert)
        alert.addTextField { (UITextField) in
            nametextField=UITextField
            nametextField.placeholder="Enter Group Name"
        }
        alert.addTextField { (UITextField) in
            desctextField=UITextField
            desctextField.placeholder="Enter Group Description"
        }
        alert.addAction(UIAlertAction(title: "Add Group", style: .default, handler: { (UIAlertAction) in
            let name=nametextField.text
            let desc=desctextField.text
            
            var dictionary:Dictionary<String,String> = [:]
            dictionary["groupName"]=name
            dictionary["groupDesc"]=desc
            
            target.childByAutoId().setValue(dictionary)
            self.tableView.reloadData()

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    func LoadData(){
        
        let target=ref.child("groupIDs").child(Auth.auth().currentUser!.uid)
        target.observe(.childAdded) { (dsnapshot) in
            var datasnapshot=dsnapshot.value as! Dictionary<String,String>
            let group=Group()
            group.groupName = datasnapshot["groupName"]!
            group.groupID = dsnapshot.key
            group.groupDescription=datasnapshot["groupDesc"]!
            
            self.data.append(group)
            self.tableView.reloadData()
        }

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="openGroup" {
            let s=segue.destination as! messageViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                print("%%%%%%%%%%%%%%%")
                s.SelectedGroup=data[indexPath.row]

            }


        }
    }


}
extension HomeViewController: UITableViewDelegate,UITableViewDataSource,SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let target=self.ref.child("groupIDs").child(Auth.auth().currentUser!.uid).child(self.data[indexPath.row].groupID)
            target.removeValue(completionBlock: { (Error, DatabaseReference) in
                if Error==nil {
                    self.data.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            })

        }
        deleteAction.image = UIImage(named: "delete")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mycell=tableView.dequeueReusableCell(withIdentifier: "Home_GroupInfoCell", for: indexPath) as! Home_GroupInfoCell
        mycell.groupLabel.text = data[indexPath.row].groupName
        mycell.groupDesc.text = data[indexPath.row].groupDescription
        mycell.delegate = self
        return mycell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "openGroup", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
