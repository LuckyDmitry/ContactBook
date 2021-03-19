//
//  RepositoryContact.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/19/21.
//

import Foundation


protocol RepositoryContact {
    
    func getContact() -> [Contact]
    
    
    
    
}

protocol RecentCallsRepository {
    
    
    func addRecent(contact: Contact)
    func getRecents() -> [Contact]
}


class Repo {
    
}

extension Repo: RepositoryContact {
    
    func getContact() -> [Contact] {
        //TODO
    }
}
