//
//  RepositoryContact.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/19/21.
//

import Foundation


protocol RepositoryContactProtocol {
    
    func getContacts() -> [Contact]
   
    func addContact(contact: Contact)
    
    func removeContact(contact: Contact)
}

class RepositoryContact: RepositoryContactProtocol {
    
    private var contacts = [Contact]()
    
    init(amountContacts: Int) {
        self.contacts = populateContacts(amountContacts: amountContacts)
    }
    
    func getContacts() -> [Contact] {
        return self.contacts
    }
    
    func addContact(contact: Contact) {
        self.contacts.append(contact)
    }

    func removeContact(contact: Contact) {
        if let indexOfElement = self.contacts.firstIndex(of: contact) {
            self.contacts.remove(at: indexOfElement)
        }
    }
    
    private func populateContacts(amountContacts: Int) -> [Contact] {
        return [
            Contact("Dmitry", "Trifonov", "89960086372"),
            Contact("Dasha", "Rassadina", "+79992223212"),
            Contact("Stepan", "Kulagin", "89960086372"),
            Contact("Yura", "Milykov", "+79994232112"),
            Contact("Ilya", "Gushin", "+79123223212"),
            Contact("Vika", "Sennikova", "+79991111111"),
            Contact("Just Seva", "", "+79991111111"),
            Contact("Maks", "Putin", "+666")
        ]
    }
}
