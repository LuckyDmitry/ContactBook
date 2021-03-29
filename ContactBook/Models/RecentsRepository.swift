//
//  RecentsRepository.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/26/21.
//

import Foundation
import CoreData
import UIKit

protocol RecentsRepository {
    
    func getCalls() throws -> [(Contact, Date)]
}

class CoreRecentsRepository: RecentsRepository {
    
    private let context: NSManagedObjectContext
    
    init?() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }

        context = appDelegate.persistentContainer.viewContext
    }

    func getCalls() throws -> [(Contact, Date)] {
        let request: NSFetchRequest<RecentCall> = RecentCall.fetchRequest()
        
        var contacts = [(Contact, Date)]()
        
        do {
            contacts = try context.fetch(request).map({
                
                guard let date = $0.timeOfCall, let phone = $0.contact?.phone else {
                    throw ContactsRepositoryError.incorrectData
                }
                return (Contact(contactName: $0.contact?.name ?? "",
                                contactSurname: $0.contact?.surname ?? "",
                                number: phone,
                                email: $0.contact?.email ?? ""),
                        date)
            })
        } catch  {
            print(error.localizedDescription)
        }
        return contacts
    }
}
