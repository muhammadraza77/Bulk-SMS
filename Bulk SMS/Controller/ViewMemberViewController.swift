//
//  ViewMemberViewController.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 10/2/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import UIKit
import SwipeCellKit
import FirebaseDatabase
import Firebase

class ViewMemberViewController: UIViewController {
    
    var contacts:[Contact]!
    var group:Group!

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        
        // Do any additional setup after loading the view.
    }
    


}

extension ViewMemberViewController : UITableViewDelegate,UITableViewDataSource,SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            let refernce = Database.database().reference()
            let target=refernce.child("groupInfo").child(Auth.auth().currentUser!.uid).child(self.group!.groupID).child(self.contacts[indexPath.row].contactID)
            target.removeValue(completionBlock: { (Error, DatabaseReference) in
                if Error==nil {
                    self.contacts.remove(at: indexPath.row)
                    self.tableView.reloadData()
                }
            })

        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mycell=tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! SwipeTableViewCell
        mycell.textLabel?.text = contacts[indexPath.row].name
        mycell.detailTextLabel?.text=contacts[indexPath.row].number
        mycell.delegate = self

        return mycell
    }

    
}
