//
//  contact.swift
//  Bulk SMS
//
//  Created by Muhammad Raza on 9/30/19.
//  Copyright © 2019 SH Tech. All rights reserved.
//

import Foundation

func == (lhs: Contact, rhs: Contact) -> Bool {
    if lhs.contactID == rhs.contactID && lhs.name == rhs.name && lhs.number == rhs.number {
        return true
    }
    return false
}
class Contact:Equatable {
    var name:String = ""
    var number:String = ""
    var contactID:String = ""
}
