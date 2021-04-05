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
    var newContactService: NewContactSerivce?
    
    override init() {
        super.init()
        contactsRepo = ContactModels.factory.getContactsRepository()
        contactsRemote = ContactModels.factory.getContactsRemote()
        birthdayService = BirthdayService()
        newContactService = NewContactSerivce()
        birthdayService?.delegate = self
        newContactService?.delegate = self
    }
}

extension ContactsPresenter: BirthdayServiceDelegate {
    func setNotification(forContact contact: Contact) {
        print(#function)
        
        guard let birthday = contact.birthday else {
            return
        }
        requestAuthorization()

        var calendar = Calendar.current.dateComponents([.day, .month], from: birthday)
        let currentDate = Date()
        var currentCalendar = Calendar.current.dateComponents([.minute, .hour], from: currentDate)
        currentCalendar.minute! += 1
        calendar.minute = currentCalendar.minute!
        calendar.hour = currentCalendar.hour
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar, repeats: true)
        
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
        vc.delegate = newContactService
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
        vc.delegate = newContactService
        view?.showContactView(vc)
    }
}

extension ContactsPresenter: NewContactServiceDelegate {
    func onSaveNotification(forContact contact: Contact) {
        birthdayService?.birthdayNotification(contact: contact)
    }
    
    func onSavingFinished(contact: Contact, mode: CNContactMode) {
        print(#function)
        switch mode {
        case .add:
            contactsRepo?.add(contact: contact)
        case .edit:
            contactsRepo?.edit(contact: contact)
        }
    }
}
