//
//  ModelsFactoty.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/31/21.
//

import Foundation


protocol ModelsFactory {
    func getContactsRepository() -> ContactsRepository
    func getContactsRemote() -> ContactsRemote
}

public enum ContactModels {
    static var factory: ModelsFactory!
}
