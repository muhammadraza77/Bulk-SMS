//
//  ViewMemberViewController.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 10/2/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import UIKit

class ViewMemberViewController: UIViewController {
    
    var contacts:[Contact]!

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        
        // Do any additional setup after loading the view.
    }
    


}

extension ViewMemberViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mycell=tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        mycell.textLabel?.text = contacts[indexPath.row].name
        mycell.detailTextLabel?.text=contacts[indexPath.row].number
        return mycell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell=tableView.cellForRow(at: indexPath)
//
//        if(cell?.accessoryType == UITableViewCell.AccessoryType.none){
//            selectedContacts.append(indexPath.row)
//            cell?.accessoryType = .checkmark
//        }else{
//            let index=selectedContacts.firstIndex(of: indexPath.row)
//            selectedContacts.remove(at: index!)
//            cell?.accessoryType = .none
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    
    
}
