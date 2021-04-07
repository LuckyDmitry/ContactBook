//
//  CoreDataContactsRepository.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/31/21.
//

import Foundation
import UIKit
import CoreData

// MARK: - CoreDataContactsRepository
public class CoreDataContactsRepository: ContactsRepository {

    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    init?() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        backgroundContext = appDelegate.backgroundContext
        context = appDelegate.persistentContainer.viewContext
    }
    
    func save(contacts: [Contact]) {
        for contact in contacts {
            add(contact: contact)
        }
    }
    
    func addNewRecentCall(contact: Contact, date: Date) {
        let recentCallsObject = RecentCall(context: context)
        recentCallsObject.timeOfCall = date
        let editRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactData")
        editRequest.predicate = NSPredicate(format: "hashVal = %@", argumentArray: [contact.hash])
        
        do {
            guard let result = try context.fetch(editRequest) as? [ContactData],
                  let contactObject = result.first else {
                return
            }
            
            contactObject.addToCalls(recentCallsObject)
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func add(contact: Contact) {
        guard let contactObject = NSEntityDescription.insertNewObject(forEntityName: "ContactData", into: backgroundContext) as? ContactData else {
            return
        }
        backgroundContext.performAndWait {
            contactObject.name = contact.name
            contactObject.surname = contact.surname
            contactObject.hashVal = Int64(contact.hash)
            contactObject.phone = contact.phoneNumber
            contactObject.email = contact.email
            contactObject.birthday = contact.birthday
            contactObject.photoUrl = contact.photoUrl
            do {
                try backgroundContext.save()
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
    
    func edit(contact: Contact) {
        print(#function)
        let editRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactData")

        editRequest.predicate = NSPredicate(format: "hashVal = %@" ,argumentArray: [contact.hash])
        
        do {
            guard let contactObject = try context.fetch(editRequest) as? [ContactData] else {
                return
            }
            contactObject.first?.name = contact.name
            contactObject.first?.surname = contact.surname
            contactObject.first?.phone = contact.phoneNumber
            contactObject.first?.email = contact.email
            contactObject.first?.photoUrl = contact.photoUrl
            contactObject.first?.birthday = contact.birthday
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func remove(contact: Contact) {
        print(#function)
        let editRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactData")
        editRequest.predicate = NSPredicate(format: "hashVal = %@" ,argumentArray: [contact.hash])
        
        do {
            guard let result = try context.fetch(editRequest) as? [ContactData],
                  let contactObject = result.first else {
                return
            }
            if let calls = contactObject.calls, calls.count > 0 {
                contactObject.name = ""
                contactObject.surname = ""
            } else {
                context.delete(contactObject)
            }
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchContacts() throws -> [Contact] {
        print(#function)
        let request: NSFetchRequest<ContactData> = ContactData.fetchRequest()
        var contasts = [Contact]()
        
        do {
            contasts = try context.fetch(request).filter({
                return !($0.name?.isEmpty ?? false) || !($0.surname?.isEmpty ?? false)
            }).map({
                let builder = Contact().builder
                builder
                    .set(name: $0.name ?? "")
                    .set(surname: $0.surname ?? "")
                    .set(phone: $0.phone ?? "")
                    .set(email: $0.email ?? "")
                    .set(photoURL: $0.photoUrl)
                    .set(hash: $0.hashVal)
                if let birthday = $0.birthday {
                    builder.set(birthday: birthday)
                }
                return builder.build()
            })
        } catch  {
            print(error.localizedDescription)
        }
        return contasts
    }
}
