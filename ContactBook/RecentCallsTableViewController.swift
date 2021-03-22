//
//  RecentCallsTableViewController.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/18/21.
//

import UIKit
import CoreData


class RecentCallTableCell: UITableViewCell {
    
    
    @IBOutlet var contactDetails: UILabel!
    @IBOutlet var dateOfCall: UILabel!
}

class RecentCallsTableViewController: UITableViewController {
    
    private let reuseIdentifier: String = "RecentCall"
    private var recentCalls = [(contact: Contact, dateOfCall: Date)]()
    private var flag = true
    
    override func viewWillAppear(_ animated: Bool) {
        if flag {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<RecentCall> = RecentCall.fetchRequest()
            
            do {
                let loadedContacts = try context.fetch(fetchRequest)
                
                for recent in loadedContacts {
                    
                    if let name = recent.contact_name, let surname = recent.contact_surname,
                       let phone_number = recent.phone_number, let date = recent.time {
                        print("LOADED")
                        let contact = Contact(name, surname, phone_number, Int(recent.contact_id))
                        recentCalls.append((contact: contact, dateOfCall: date))
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
            flag = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)),
                                                          name: Notification.Name("addContact"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeContacsName(_:)),
                                                          name: Notification.Name("changeContactDataInsideSection"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRemoved(_:)),
                                                          name: Notification.Name("updateRemoved"), object: nil)
    }
    
    func saveRecents() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "RecentCall", in: context) else {
            return
        }
        guard let taskObject = NSManagedObject(entity: entity, insertInto: context) as? RecentCall else {
            return
        }
        
        if let item = recentCalls.last {
            taskObject.contact_id = Int64(item.contact.getContactId())
            taskObject.time = item.dateOfCall
            taskObject.contact_name = item.contact.getName()
            taskObject.phone_number = item.contact.getPhoneNumber()
            taskObject.contact_surname = item.contact.getSurname()
        }
        
        do {
            try context.save()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @objc func methodOfReceivedNotification(_ notification: Notification) {
        guard let contact = notification.object as? Contact else {
            return
        }
        addRecentCall(contact: contact)
        saveRecents()
    }
    
    @objc func updateRemoved(_ notification: Notification) {
        
        guard let contact = notification.object as? Contact else {
            return
        }
        
        var indexes: [IndexPath] = []
        
        for (idx, item) in recentCalls.enumerated() {
            if item.contact.getContactId() == contact.getContactId() {
                item.contact.setNewName("")
                item.contact.setNewSurname("")
                indexes.append(IndexPath(row: idx, section: 0))
            }
        }
        self.tableView.reloadRows(at: indexes, with: .automatic)
    }
    
    @objc func changeContacsName(_ notification: Notification) {
        guard let contact = notification.object as? Contact else {
            return
        }
        var indexes: [IndexPath] = []
        
        for (idx, item) in recentCalls.enumerated() {
            if item.contact.getContactId() == contact.getContactId() {
                item.contact.setNewName(contact.getName())
                item.contact.setNewSurname(contact.getSurname())
                indexes.append(IndexPath(row: idx, section: 0))
            }
        }
        self.tableView.reloadRows(at: indexes, with: .automatic)
    }
    
    func addRecentCall(contact: Contact?) {
        
        guard let checkedContact = contact else {
            return
        }
        recentCalls.append((contact: checkedContact, dateOfCall: Date()))
        self.tableView.reloadData()
        saveRecents()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentCalls.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! RecentCallTableCell
        
        let contact = recentCalls[indexPath.row].contact
        let date = recentCalls[indexPath.row].dateOfCall
        if (contact.getName().isEmpty) {
            cell.contactDetails.text = contact.getPhoneNumber()
        }
        else{
            cell.contactDetails.text = contact.getName() + " " + contact.getSurname()
        }
        cell.dateOfCall.text = parseDate(date: date)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func parseDate(date: Date) -> String {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        
        guard let hour = components.hour, let minute = components.minute else {
            return ""
        }
        
        let dateString = String(hour) + ":" + (String(minute).count == 1 ? "0" + String(minute) :  String(minute))
        return dateString
    }
}
