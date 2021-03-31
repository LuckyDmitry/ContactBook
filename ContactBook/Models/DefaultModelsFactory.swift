//
//  DefaultModelsFactory.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/31/21.
//

import Foundation


class DefaultModelsFactory: ModelsFactory {
    
    private let contactsRepository: ContactsRepository!
    private let contactsRemote: ContactsRemote!
    
    
    init() {
        self.contactsRepository = CoreDataContactsRepository()
        self.contactsRemote = RemoteContactsDataTask()
    }
    
    func getContactsRepository() -> ContactsRepository {
        return contactsRepository
    }
    
    func getContactsRemote() -> ContactsRemote {
        return contactsRemote
    }
}
