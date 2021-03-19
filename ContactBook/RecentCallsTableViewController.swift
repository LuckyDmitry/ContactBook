//
//  RecentCallsTableViewController.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/18/21.
//

import UIKit


class RecentCallTableCell: UITableViewCell {
    
    
    @IBOutlet var contactDetails: UILabel!
    @IBOutlet var dateOfCall: UILabel!
}

class RecentCallsTableViewController: UITableViewController {
    
    
    private var reuseIdentifier: String = "RecentCall"
    private var recentCalls = [(contact: Contact, dateOfCall: Date)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)),
                                                          name: Notification.Name("addContact"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeContacsName(_:)),
                                                          name: Notification.Name("changeContactName"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRemoved(_:)),
                                                          name: Notification.Name("updateRemoved"), object: nil)
    }
    
    @objc func methodOfReceivedNotification(_ notification: Notification) {
        guard let contact = notification.object as? Contact else {
            return
        }
        addRecentCall(contact: contact)
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
    
    private func addRecentCall(contact: Contact?) {
        
        guard let checkedContact = contact else {
            return
        }
        
        recentCalls.append((contact: checkedContact, dateOfCall: Date()))
        self.tableView.reloadData()
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
        cell.dateOfCall.text = parseData(date: date)
        return cell
    }
    
    private func parseData(date: Date) -> String {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        
        guard let hour = components.hour, let minute = components.minute else {
            return ""
        }
        
        let dateString = String(hour) + ":" + String(minute)
        return dateString
    }
}

