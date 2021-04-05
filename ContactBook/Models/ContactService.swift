//
//  ContactService.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 4/5/21.
//

import Foundation
import ContactsUI

public enum CNContactMode {
    case add
    case edit
}

public protocol NewContactServiceDelegate: class {
    func onSavingFinished(contact: Contact, mode: CNContactMode)
    func onSaveNotification(forContact contact: Contact)
}

public class NewContactSerivce: NSObject {
    
    weak var delegate: NewContactServiceDelegate?
    
    public override init() {
        super.init()
        
    }
}

extension NewContactSerivce: CNContactViewControllerDelegate{
    public func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        print(#function)
        guard let contact = contact else {
            return
        }
        let newContact = Contact().builder
            .set(name: contact.givenName)
            .set(surname: contact.familyName)
            
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            newContact.set(phone: phoneNumber)
        }
        
        if let birthday = contact.birthday?.date {
            newContact.set(birthday: birthday)
            print(birthday)
            delegate?.onSaveNotification(forContact: newContact.build())
        }
        
        var finalContact: Contact!
        if !contact.note.isEmpty, let hash = Int64(contact.note) {
            newContact.set(hash: hash)
            finalContact = newContact.build()
            delegate?.onSavingFinished(contact: finalContact, mode: CNContactMode.edit)
        } else {
            finalContact = newContact.build()
            delegate?.onSavingFinished(contact: finalContact, mode: CNContactMode.add)
        }
        
    }
}
