//
//  ContactsRepository.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/25/21.
//

import CoreData
import UIKit

enum ContactsRepositoryError: Error {
    case incorrectData
    case incorectDelegate
    case contextNotFound
}

protocol ContactsRepository {
    
    func add(contact: Contact)
    
    func edit(contact: Contact)
    
    func remove(contact: Contact)
    
    func addNewRecentCall(contact: Contact, date: Date)
    
    func save(contacts: [Contact])
    
    func fetchContacts() throws -> [Contact]
}
