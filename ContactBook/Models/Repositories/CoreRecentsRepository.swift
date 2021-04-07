//
//  CoreRecentsRepository.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/31/21.
//

import Foundation
import CoreData
import UIKit

public class CoreRecentsRepository: RecentsRepository {
    
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
                
                guard let date = $0.timeOfCall else {
                    throw ContactsRepositoryError.incorrectData
                }
                return (Contact().builder
                            .set(name: $0.contact?.name ?? "")
                            .set(surname: $0.contact?.surname ?? "")
                            .set(phone: $0.contact?.phone ?? "")
                            .set(email: $0.contact?.email ?? "")
                            .set(hash: $0.contact?.hashVal ?? 0)
                            .build(),
                        date)
            })
        } catch  {
            print(error.localizedDescription)
        }
        
        return contacts
    }
}
