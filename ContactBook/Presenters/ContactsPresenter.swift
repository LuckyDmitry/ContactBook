//
//  ContactsPresenter.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/30/21.
//

import Foundation
import ContactsUI

// MARK: - Protocol

protocol ContactsView: class {
    func showContactView(_ viewController: UIViewController)
    func showContacts(_ contacts: [Contact])
}

protocol ContactsViewOutput {
    func addContactButtonPressed()
    func contactPressed(contact: Contact)
    func contactRemove(contact: Contact)
    func viewWillLoad()
    func addCall(contact: Contact, date: Date)
}

// MARK: - Class

class ContactsPresenter: NSObject {
    
    private var contactsRepo: ContactsRepository?
    private var contactsRemote: ContactsRemote?
    weak var view: ContactsView?
    var birthdayService: BirthdayService?
    
    override init() {
        super.init()
        contactsRepo = ContactModels.factory.getContactsRepository()
        contactsRemote = ContactModels.factory.getContactsRemote()
        birthdayService = BirthdayService()
        birthdayService?.delegate = self
    }
}

extension ContactsPresenter: BirthdayServiceDelegate {
    func setNotification(forContact contact: Contact) {
        print(#function)
        requestAuthorization()
        var date = DateComponents()
        date.hour = 7
        date.minute = 58
        date.day = 5
        date.month = 4

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Happy birthday"
        content.body = "Today birthday's \(contact.name) \(contact.surname)"
        
        let identifier = String(contact.hash)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func requestAuthorization() {
        print(#function)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (response, error) in
            print(response)
        }
    }
}

extension ContactsPresenter: ContactsViewOutput {
    func contactPressed(contact: Contact) {
        print(#function)
        let contactObject = CNMutableContact()
        contactObject.givenName = contact.name
        contactObject.familyName = contact.surname
        contactObject.note = String(contact.hash)
        contactObject.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberiPhone, value: CNPhoneNumber(stringValue: contact.phoneNumber))]
        
        let vc = CNContactViewController(for: contactObject)
        vc.allowsEditing = true
        vc.allowsActions = true
        vc.hidesBottomBarWhenPushed = true
        vc.delegate = self
        view?.showContactView(vc)
    }
    
    func contactRemove(contact: Contact) {
        print(#function)
        DispatchQueue.global(qos: .userInteractive).async {
            self.contactsRepo?.remove(contact: contact)
            do {
                guard let contacts = try self.contactsRepo?.fetchContacts() else {
                    return
                }
                self.view?.showContacts(contacts)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addCall(contact: Contact, date: Date) {
        print(#function)
        let phoneNumber = contact.phoneNumber.filter("0123456789".contains)
        
        guard !phoneNumber.isEmpty else {
            return
        }
        DispatchQueue.global(qos: .background).async {
            self.contactsRepo?.addNewRecentCall(contact: contact, date: Date())
        }
    }
    
    func viewWillLoad() {
        print(#function)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let repositoryContacts = try self.contactsRepo?.fetchContacts() else {
                    return
                }
                if (repositoryContacts.isEmpty) {
                    guard let remoteContacts = try self.contactsRemote?.getContacts() else {
                        return
                    }
                    self.view?.showContacts(remoteContacts)
                    DispatchQueue.global(qos: .background).async {
                        self.contactsRepo?.save(contacts: remoteContacts)
                    }
                } else {
                    self.view?.showContacts(repositoryContacts)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addContactButtonPressed() {
        let contact = CNContact()
        let vc = CNContactViewController(forNewContact: contact)
        vc.delegate = self
        view?.showContactView(vc)
    }
}

extension ContactsPresenter: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        print(#function)
        guard let contact = contact else {
            return
        }
        let newContact = Contact().builder
            .set(name: contact.givenName)
            .set(surname: contact.familyName)
            
        if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
            newContact.set(phone: phoneNumber)
        }
        
        if let birthday = contact.birthday?.date {
            newContact.set(birthday: birthday)
        }
        
        var finalContact: Contact!
        if !contact.note.isEmpty, let hash = Int64(contact.note) {
            newContact.set(hash: hash)
            finalContact = newContact.build()
            contactsRepo?.edit(contact: finalContact)
        } else {
            finalContact = newContact.build()
            contactsRepo?.add(contact: finalContact)
        }
        
        setNotification(forContact: finalContact)
    }
}
