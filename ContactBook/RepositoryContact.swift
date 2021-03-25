//
//  RepositoryContact.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/19/21.
//

import Foundation

fileprivate struct ContactDecodable: Decodable {
    var contacts: [Contact]
}

protocol RepositoryContactProtocol {
    
    func getContacts() -> [Contact]
   
    func addContact(contact: Contact)
    
    func removeContact(contact: Contact)
}

class RepositoryContact: RepositoryContactProtocol {
    
    private var contacts = [Contact]()
    private let url = "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json"
    
    init() {
     
    }
    
    public func fetchData(handlerReceivedContacts handler: @escaping ((_ data: [Contact]?) -> Void)) {
        let defaults = UserDefaults.standard
        let value = defaults.integer(forKey: SettingOfRequestMethod.settingKey.rawValue)
        let method = SettingOfRequestMethod.chooseSettings(row: value)
        
        switch method {
        case SettingOfRequestMethod.enumParsingApproachWithDispatchWorkItem:
            let work = DispatchWorkItem.init(qos: .utility){
                self.enumParsingApproachWithDispatchWorkItem()
            }
            DispatchQueue.global().async(execute: work)
            work.notify(queue: .main, execute: {
                handler(self.contacts)
            })
            
        case SettingOfRequestMethod.withOperationQueue:
            if let url = URL(string: url) {
                let operation = JsonRequestOperation(handler: handler, url: url)
                let queue = OperationQueue()
                queue.addOperation(operation)
            }
            
        case SettingOfRequestMethod.manualParsingApproach:
            manualParsingApproach(closure: handler)
            
        case SettingOfRequestMethod.enumParsingApproach:
            enumParsingApproach(closure: handler)
        case .settingKey:
            return
        }
    }
    
    func getContacts() -> [Contact] {
        return self.contacts
    }
    
    func addContact(contact: Contact) {
        self.contacts.append(contact)
    }

    func removeContact(contact: Contact) {
        if let indexOfElement = self.contacts.firstIndex(of: contact) {
            self.contacts.remove(at: indexOfElement)
        }
    }
    
    private func manualParsingApproach(closure: @escaping(([Contact]) -> Void)) {
        print("manualParsingApproach")
        guard let url = URL(string: url) else {
            return
        }
       
        let urlRequest = URLRequest(url: url)
        let request = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else {
                return
            }
        
            var result: Any?
            do {
                result = try JSONSerialization.jsonObject(with: data, options: [])
                
            } catch {
                print(error.localizedDescription)
            }
            
            guard let res = result, let arrayOfContacts = res as? [Any] else {
                return
            }
            
            self.contacts.reserveCapacity(arrayOfContacts.count)
            
            for contact in arrayOfContacts {
                guard let contactAsDictionary = contact as? [String: Any] else {
                    return
                }
                
                guard let name = contactAsDictionary["firstname"] as? String,
                      let surname = contactAsDictionary["lastname"] as? String,
                      let phone = contactAsDictionary["phone"] as? String else {
                    return
                }
                self.contacts.append(Contact(name, surname, phone))
            }
            
            closure(self.contacts)
        }
        request.resume()
    }
    
    private func enumParsingApproachWithDispatchWorkItem() {
        print("enumParsingApproachWithDispatchWorkItem")
        guard let checkedUrl = URL(string: url) else {
            return
        }
        
        guard let data = try? Data(contentsOf: checkedUrl) else {
            return
        }
        
        do {
            let result = try JSONDecoder().decode([Contact].self, from: data)
            self.contacts = result.map{
                Contact($0.getName(), $0.getSurname(), $0.getPhoneNumber())
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func enumParsingApproach(closure: @escaping(([Contact]) -> ())) {
        print("enumParsingApproach")
        guard let url = URL(string: url) else {
            return
        }
       
        let urlRequest = URLRequest(url: url)
        let request = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let result = try JSONDecoder().decode([Contact].self, from: data)
                self.contacts = result.map{
                    Contact($0.getName(), $0.getSurname(), $0.getPhoneNumber())
                }
            } catch {
                print(error.localizedDescription)
            }
            closure(self.contacts)
        }
        request.resume()
    }
}


fileprivate final class JsonRequestOperation: Operation {
    
    let handler: ([Contact]) -> ()
    let url: URL
    
    init(handler: @escaping ([Contact]) -> (), url: URL) {
        self.handler = handler
        self.url = url
        super.init()
    }
    
    override func main() {
        print("JsonRequestOperation")
        let urlRequest = URLRequest(url: url)
        let request = URLSession.shared.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else {
                return
            }
            var contacts = [Contact]()
            do {
                let result = try JSONDecoder().decode([Contact].self, from: data)
                contacts = result.map{
                    Contact($0.getName(), $0.getSurname(), $0.getPhoneNumber())
                }
            } catch {
                print(error.localizedDescription)
            }
            self.handler(contacts)
        }
        request.resume()
    }
}
