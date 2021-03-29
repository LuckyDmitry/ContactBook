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
    
    func saveNewContact(contact: Contact)
    
    func editContact(contact: Contact)
    
    func removeContact(contact: Contact)
    
    func addNewRecentCall(contact: Contact, date: Date)
    
    func fetchContacts() throws -> [Contact]
}

class CoreDataContactsRepository: ContactsRepository {

    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    init?() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        backgroundContext = appDelegate.backgroundContext
        context = appDelegate.persistentContainer.viewContext
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
    
    func saveNewContact(contact: Contact) {

        guard let contactObject = NSEntityDescription.insertNewObject(forEntityName: "ContactData", into: backgroundContext) as? ContactData else {
            return
        }
        backgroundContext.performAndWait {
            
            contactObject.name = contact.name
            contactObject.surname = contact.surname
            contactObject.hashVal = Int64(contact.hash)
            contactObject.phone = contact.phoneNumber
            contactObject.email = contact.email
            do {
                try backgroundContext.save()
            } catch  {
                print(error.localizedDescription)
            }
        }
    }
    
    func editContact(contact: Contact) {
        
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
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeContact(contact: Contact) {
        
        let editRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactData")
        editRequest.predicate = NSPredicate(format: "hashVal = %@" ,argumentArray: [contact.hash])
        
        do {
            guard let result = try context.fetch(editRequest) as? [ContactData],
                  let contactObject = result.first else {
                return
            }
            contactObject.name = ""
            contactObject.surname = ""
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchContacts() throws -> [Contact] {
        
        let request: NSFetchRequest<ContactData> = ContactData.fetchRequest()
        
        var contasts = [Contact]()
        do {
            contasts = try context.fetch(request).filter({
                
                return !($0.name?.isEmpty ?? false) || !($0.surname?.isEmpty ?? false)
            }) .map({
                return Contact(contactName: $0.name ?? "",
                               contactSurname: $0.surname ?? "",
                               number: $0.phone ?? "",
                               email: $0.email ?? "",
                               oldHash: $0.hashVal)
            })
        } catch  {
            print(error.localizedDescription)
        }
        return contasts
    }

}
