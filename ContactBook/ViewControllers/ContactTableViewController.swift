import UIKit
import CoreData

class ContactTableViewController: UITableViewController {
    
    private var mapContacts: Dictionary<Character, [Contact]> = [:]
    private var tableCellSections: [Character] = []
    var updateUI: (([Contact]) -> Void)?
    private var remoteContactsRepository: RemoteContacts?
    private var refresher: UIRefreshControl?
    private var coreContactRepository: ContactsRepository?
    
    @IBAction func onAddItemButtonPressed(_ sender: UIBarButtonItem) {
        
        let vc = ContactDetailsViewController(contactMode: ContactMode.add, contact: Contact(contactName: "", contactSurname: "", number: "", email: ""))
        let modifiredViewController = setOnResultListener(DetailsViewController: vc)
        
        if let modifiredViewController = modifiredViewController {
            navigationController?.pushViewController(modifiredViewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.selectedIndex = 1
        updateUI = {contacts in

            self.mapContacts = Dictionary(grouping: contacts){ contact in
                contact.name.uppercased().first ?? " "
            }
            
            self.tableCellSections.removeAll()
            
            for key in self.mapContacts.keys {
                self.tableCellSections.append(key)
            }
            
            self.tableCellSections.sort()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refresher?.endRefreshing()
            }
        }
        remoteContactsRepository = RemoteContactsDataTask()
        coreContactRepository = CoreDataContactsRepository()
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let repositoryContacts = try self.coreContactRepository?.fetchContacts() else {
                    return
                }
                if (repositoryContacts.isEmpty) {
                    guard let remoteContacts = try self.remoteContactsRepository?.getContacts() else {
                        return
                    }
                    self.updateUI?(remoteContacts)
                    DispatchQueue.global(qos: .background).async {
                        for contact in remoteContacts {
                            self.coreContactRepository?.saveNewContact(contact: contact)
                        }
                    }
                } else {
                    self.updateUI?(repositoryContacts)
                }
            } catch URLError.incorrectUrl {
                self.showMessage(controller: self, message: "Incorrect url, try to reopen app", seconds: 1.0)
            } catch URLError.errorGettingData {
                self.showMessage(controller: self, message: "Check your internet connection and try again", seconds: 1.0)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return tableCellSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return mapContacts[tableCellSections[section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return String(tableCellSections[section])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        
        if let contact = mapContacts[tableCellSections[indexPath.section]]?[indexPath.row] {
            cell.textLabel?.text = (contact.name) + " " + (contact.surname)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = mapContacts[tableCellSections[indexPath.section]]?[indexPath.row] else {
            return
        }
        
        let contactDetailsViewController = ContactDetailsViewController(contact: contact)
        if let vc = setOnResultListener(DetailsViewController: contactDetailsViewController) {
            navigationController?.pushViewController(vc, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            guard let contact = mapContacts[self.tableCellSections[indexPath.section]]?[indexPath.row] else {
                return
            }
            DispatchQueue.global(qos: .userInteractive).async {
                self.coreContactRepository?.removeContact(contact: contact)
                do {
                    guard let contacts = try self.coreContactRepository?.fetchContacts() else {
                        return
                    }
                    self.updateUI?(contacts)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Calling"){
            [weak self] (action, view, completionHandler) in
            self?.makeCall(idx: indexPath)
            completionHandler(true)
        }
        action.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }    
}

extension ContactTableViewController {
    
    private func makeCall(idx: IndexPath) {
        
        guard let contact = mapContacts[tableCellSections[idx.section]]?[idx.row] else {
            return
        }
        
        let phoneNumber = contact.phoneNumber.filter("0123456789".contains)
        
        guard URL(string: "tel://" + phoneNumber) != nil && !phoneNumber.isEmpty else {
            showMessage(controller: self, message: "You can't call this number. Make sure number is correct", seconds: 0.5)
            return
        }
        coreContactRepository?.addNewRecentCall(contact: contact, date: Date())
    }
    
    private func showMessage(controller: UIViewController,
                               message: String,
                               seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.1
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    private func setOnResultListener(DetailsViewController: UIViewController) -> UIViewController? {
        
        guard let vc = DetailsViewController as? ContactDetailsViewController else {
            return nil
        }
        
        vc.competion = { [weak self] newContact, mode in
            
            guard let contact = newContact else {
                return
            }
            
            if (mode == ContactMode.edit) {
                self?.coreContactRepository?.editContact(contact: contact)
            } else {
                self?.coreContactRepository?.saveNewContact(contact: contact)
            }
            guard let contacts = try? self?.coreContactRepository?.fetchContacts() else {
                return
            }
            self?.updateUI?(contacts)
        }
        return vc
    }
}
