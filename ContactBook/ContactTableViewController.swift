import UIKit
import CoreData

class ContactTableViewController: UITableViewController {
    
    private var mapContacts: Dictionary<Character, [Contact]>?
    private var tableCellSections = [Character]()
    var closure: (([Contact]?) -> Void)?
    private var contactsRepository: RepositoryContact?
    private var refresher: UIRefreshControl?
    
    @IBAction func onAddItemButtonPressed(_ sender: UIBarButtonItem) {
        
        let vc = ContactDetailsViewController(contactMode: ContactMode.Add, contact: Contact("", "", ""), indexPath: nil)
        let modifiredViewController = settingClosureForDetailsView(DetailsViewController: vc)
        
        if let modifiredViewController = modifiredViewController {
            navigationController?.pushViewController(modifiredViewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.selectedIndex = 1
        closure = {[weak self] contacts in
            
            guard let contacts = contacts else {
                return
            }
            
            self?.mapContacts = Dictionary(grouping: contacts){ contact in
                (contact.getName().uppercased().first ?? " ")
            }
            self?.tableCellSections = [Character]()
            if let mapContacts = self?.mapContacts {
                for (key, _)  in mapContacts {
                    self?.tableCellSections.append(key)
                }
            }
            self?.tableCellSections.sort()
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refresher?.endRefreshing()
                
            }
        }
        
        self.refresher = UIRefreshControl()
        self.refresher?.addTarget(self, action: #selector(updateData(_:)), for: .valueChanged)
        refresher?.tintColor = .red
        refresher?.attributedTitle = NSAttributedString(string: "Fetching contacts data", attributes: nil)
        tableView.refreshControl = refresher
        refresher?.beginRefreshing()
        contactsRepository = RepositoryContact()
        updateData(nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return tableCellSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let size = mapContacts?[tableCellSections[section]]?.count else {
            return 0
        }
        return size
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return String(tableCellSections[section])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        
        let contact = mapContacts?[tableCellSections[indexPath.section]]?[indexPath.row]
        cell.textLabel?.text = (contact?.getName() ?? "") + " " + (contact?.getSurname() ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = mapContacts?[tableCellSections[indexPath.section]]?[indexPath.row] else {
            return
        }
        
        let contactDetailsViewController = ContactDetailsViewController(contact: contact, indexPath: indexPath)
        if let vc = settingClosureForDetailsView(DetailsViewController: contactDetailsViewController) {
            navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            deleteContactInTable(indexPath: indexPath, updateRecentContacts: true)
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
    
    @objc private func updateData(_ t: Any?) {
        guard let checkedClosure = closure else {
            return
        }
        contactsRepository?.fetchData(handlerReceivedContacts: checkedClosure)
    }
    
    private func makeCall(idx: IndexPath) {
        print(mapContacts![tableCellSections[idx.section]]![idx.row])
        
        guard let contact = mapContacts?[tableCellSections[idx.section]]?[idx.row] else {
            return
        }
        
        let phoneNumber = contact.getPhoneNumber().filter("0123456789".contains)
        
        guard let number = URL(string: "tel://" + phoneNumber) else {
            customWarning(controller: self,
                          message: "You can't call this number. Make sure number is correct", seconds: 1)
            return
        }
        
        UIApplication.shared.open(number)
        NotificationCenter.default.post(name: Notification.Name("addContact"), object: contact)
    }
    
    private func customWarning(controller: UIViewController,
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
    
    private func deleteContactInTable(indexPath: IndexPath, updateRecentContacts: Bool = false) {
        let tableSection: Character = tableCellSections[indexPath.section]
        
        guard let contact = mapContacts?[tableSection]?[indexPath.row] else {
            return
        }
        contactsRepository?.removeContact(contact: contact)
        
        mapContacts?[tableSection]?.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        if (mapContacts?[tableSection]?.count == 0){
            
            tableCellSections.remove(at: indexPath.section)
            mapContacts?.removeValue(forKey: tableSection)
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            tableView.deleteSections(indexSet, with: .none)
        }
        
        if (updateRecentContacts) {
            NotificationCenter.default.post(name: Notification.Name("updateRemoved"), object: contact)
        } else {
            NotificationCenter.default.post(name: Notification.Name("changeContactDataInsideSection"), object: contact)
        }
    }
    
    private func settingClosureForDetailsView(DetailsViewController: UIViewController) -> UIViewController? {
        
        guard let vc = DetailsViewController as? ContactDetailsViewController else {
            return nil
        }
        
        vc.competion = { [weak self] contact, indexPath in
            DispatchQueue.main.async {
                
                guard let checkedContact = contact else {
                    return
                }
                
                guard let key = checkedContact.getName().uppercased().first else {
                    return
                }
                
                if let indexPath = indexPath {
                    guard let sectionTableTitle = self?.tableCellSections[indexPath.section] else {
                        return
                    }
                    
                    guard let firstLetterOfName = checkedContact.getName().uppercased().first else {
                        return
                    }
                    
                    if (sectionTableTitle == firstLetterOfName) {
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        NotificationCenter.default.post(name: Notification.Name("changeContactDataInsideSection"), object: checkedContact)
                        return
                    }
                    self?.deleteContactInTable(indexPath: indexPath) // if a first letter of name changed
                }
    
                if (self?.mapContacts?.keys.contains(key) ?? false) {
                    self?.mapContacts?[key]?.append(checkedContact)
                    guard let idx = self?.tableCellSections.firstIndex(of: key) else {
                        return
                    }
                    self?.mapContacts?[key]?.sort(by: { (first, second) -> Bool in
                        return first.getName() > second.getName()
                    })
//                    self?.tableView.reloadSections(IndexSet(integer: idx), with: .automatic)
                    self?.tableView.reloadData()
                    
                } else {
                    self?.mapContacts?[key] = [checkedContact]
                    self?.tableCellSections.append(key)
                    self?.tableCellSections.sort()
                    self?.tableView.reloadData()
                }
                self?.contactsRepository?.addContact(contact: checkedContact)
            }
        }
        return vc
    }
}
