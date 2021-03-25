//
//  Contact.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/17/21.
//

import Foundation

class Contact: Decodable {
    
    private var name: String
    private var surname: String
    private var phoneNumber: String
    var email: String?
    private static var id: Int = 0
    private var contactId: Int = 0

    init (_ contactName: String, _ contactSurname: String, _ number: String) {
        name = contactName
        surname = contactSurname
        phoneNumber = number
        contactId = Contact.id
        Contact.id += 1
    }
    
    init (_ contactName: String, _ contactSurname: String, _ number: String, _ id: Int) {
        name = contactName
        surname = contactSurname
        phoneNumber = number
        contactId = id
    }
    
    private enum CodingKeys: String, CodingKey {
        case name = "firstname"
        case surname = "lastname"
        case phoneNumber = "phone"
        case email = "email"
    }

    public func getName() -> String {
        return name
    }
    
    public func getSurname() -> String {
        return surname
    }
    
    public func getPhoneNumber() -> String {
        return String(phoneNumber)
    }
    
    public func getContactId() -> Int {
        return contactId
    }
    
    public func setNewName(_ name: String) {
        self.name = name
    }
    
    public func setNewSurname(_ surname: String) {
        self.surname = surname
    }
    
    public func setNewPhoneNumber(_ phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.getContactId() == rhs.getContactId()
    }
}
