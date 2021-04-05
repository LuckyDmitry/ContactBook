//
//  FileManagerContactsRepository.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/31/21.
//

import Foundation

private class ContactJsonEntry: Codable {
    var entry: [String: ContactJsonDetails]
    
    init() {
        entry = [:]
    }
    init(entry:  [String: ContactJsonDetails]) {
        self.entry = entry
    }
}

private class ContactJsonDetails: Codable {
    var name: String
    var surname: String
    var phone: String
    var email: String
    var calls: [Date]?
    init(name: String, surname: String, phone: String, email: String, calls: [Date]? = nil) {
        self.name = name
        self.surname = surname
        self.phone = phone
        self.email = email
        self.calls = calls
    }
}

public class FileManagerContactsRepository: ContactsRepository {

    private var fileManager: FileManager
    private let fileUrl: URL
    private let encoder: JSONEncoder
    
    init?() {
        encoder = JSONEncoder()
        fileManager = FileManager.default
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("contacts.json") else {
            return nil
        }
        fileUrl = url
        print(fileUrl.path)
        if !(fileManager.fileExists(atPath: fileUrl.path)) {
            fileManager.createFile(atPath: fileUrl.path,
                                    contents: nil,
                                    attributes: [FileAttributeKey.creationDate: Date()])
        }
    }
    
    func add(contact: Contact) {
        guard let dataContacts = getDataObject() else{
            return
        }

        var result = try? JSONDecoder().decode([String: ContactJsonDetails].self, from: dataContacts)
        let key = String(contact.hash)
        result?[key] = transfrom(from: contact)

        if let dataResult = try? encoder.encode(result),
           let file = FileHandle(forWritingAtPath: fileUrl.path) {
            file.write(dataResult)
        }
    }
    
    func save(contacts: [Contact]) {
        let jsonContacts = ContactJsonEntry()
        for contact in contacts {
            jsonContacts.entry[String(contact.hash)] = transfrom(from: contact)
        }
        
        if let dataResult = try? encoder.encode(jsonContacts.entry),
           let file = FileHandle(forWritingAtPath: fileUrl.path) {
            file.write(dataResult)
        }
    }
    
    func edit(contact: Contact) {
        guard let data = getDataObject() else {
            return
        }
        do {
            var contacts = try JSONDecoder().decode([String: ContactJsonDetails].self, from: data)
            let key = String(contact.hash)
            if contacts[key] != nil {
                contacts[key] = transfrom(from: contact, calls: contacts[key]?.calls)
            }
            if let dataResult = try? encoder.encode(contacts),
               let file = FileHandle(forWritingAtPath: fileUrl.path) {
                file.write(dataResult)
            }
        } catch {
            print(error)
        }
    }
    
    func remove(contact: Contact) {
        guard let dataContacts = getDataObject() else {
            return
        }
        
        do {
            var contacts = try JSONDecoder().decode([String: ContactJsonDetails].self, from: dataContacts)
            let key = String(contact.hash)
            if contacts[key]?.calls != nil {
                contacts[key] = transfrom(from: contact, calls: contacts[key]?.calls)
            } else {
                contacts.removeValue(forKey: key)
            }
            if let dataResult = try? encoder.encode(contacts),
               let file = FileHandle(forWritingAtPath: fileUrl.path) {
                file.write(dataResult)
            }
        } catch {
            print(error)
        }
    }
    
    func addNewRecentCall(contact: Contact, date: Date) {
        guard let data = getDataObject() else {
            return
        }
        do {
            let contacts = try JSONDecoder().decode([String: ContactJsonDetails].self, from: data)
            let key = String(contact.hash)
            if contacts[key]?.calls == nil {
                contacts[key]?.calls = [Date]()
            }
            contacts[key]?.calls?.append(date)
            if let dataResult = try? encoder.encode(contacts),
               let file = FileHandle(forWritingAtPath: fileUrl.path) {
                file.write(dataResult)
            }
            
        } catch {
            print(error)
        }
    }
    
    func fetchContacts() throws -> [Contact] {
        guard let data = getDataObject(), !data.isEmpty else {
            return []
        }

        let result = try JSONDecoder().decode([String: ContactJsonDetails].self, from: data)
        let contacts = result.map({
            Contact().builder
                .set(name: $1.name)
                .set(surname: $1.surname)
                .set(phone: $1.phone)
                .set(email: $1.email)
                .set(hash: Int64($0) ?? 0)
                .build()
        })
           
        print(contacts.count)
        return contacts
    }
    
    private func transfrom(from contact: Contact, calls: [Date]? = nil) -> ContactJsonDetails {
        return ContactJsonDetails(name: contact.name, surname: contact.surname, phone: contact.phoneNumber, email: contact.email, calls: calls)
    }
    
    private func getDataObject() -> Data? {
        var data: Data?
        do {
            data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
        } catch {
            print(error)
        }
        return data
    }
}
