import UIKit

class ContactTableViewController: UITableViewController {
    
    var contacts = [
        Contact("Dmitry", "Trifonov", "89960086372"),
        Contact("Dasha", "Rassadina", "+79992223212"),
        Contact("Stepan", "Kulagin", "89960086372"),
        Contact("Yura", "Milykov", "+79994232112"),
        Contact("Ilya", "Gushin", "+79123223212"),
        Contact("Vika", "Sennikova", "+79991111111"),
        Contact("Just Seva", "", "+79991111111"),
        Contact("Maks", "Putin", "+666")
    ]
    
    var mapContacts: Dictionary<Character, [Contact]>?
    var sections = [Character]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapContacts = Dictionary(grouping: contacts){ contact in
            (contact.getName().uppercased().first ?? " ")
        }
        
        if let mapContacts = mapContacts {
            for (key, _)  in mapContacts {
                sections.append(key)
            }
        }
        
        sections.sort()
    }
    
    @IBAction func onAddItemButtonPressed(_ sender: UIBarButtonItem) {
        
        let vc = ContactDetailsViewController(contactMode: ContactMode.Add, contact: Contact("", "", ""), indexPath: nil)
        let modifiredViewController = settingClosureForDetailsView(DetailsViewController: vc)
        if let modifiredViewController = modifiredViewController {
            navigationController?.pushViewController(modifiredViewController, animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let size = mapContacts?[sections[section]]?.count else {
            return 0
        }
        
        return size
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(sections[section])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        
        let contact = mapContacts?[sections[indexPath.section]]?[indexPath.row]
        cell.textLabel?.text = (contact?.getName() ?? "") + " " + (contact?.getSurname() ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = mapContacts?[sections[indexPath.section]]?[indexPath.row] else {
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
            deleteElement(indexPath: indexPath, updateRecent: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal,
                                        title: "Calling") { [weak self] (action, view, completionHandler) in
            
            self?.makeCall(idx: indexPath)
            completionHandler(true)
        }
        
        action.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }    
}

extension ContactTableViewController {
    
    private func makeCall(idx: IndexPath) {
        
        let contact = mapContacts?[sections[idx.section]]?[idx.row]
        if (contact?.getPhoneNumber().isEmpty ?? false) {
            customWarning(controller: self, message: "You can't call because a phone number is empty", seconds: 1)
        }
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
    
    private func deleteElement(indexPath: IndexPath, updateRecent: Bool = false) {
        let key: Character = sections[indexPath.section]
        
        let contact = mapContacts?[key]?[indexPath.row]
        mapContacts?[key]?.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        
        if (mapContacts?[key]?.count == 0){
            sections.remove(at: indexPath.section)
            mapContacts?.removeValue(forKey: key)
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            tableView.deleteSections(indexSet, with: .none)
            if (updateRecent) {
                NotificationCenter.default.post(name: Notification.Name("updateRemoved"), object: contact)
            }
            else {
                NotificationCenter.default.post(name: Notification.Name("changeContactName"), object: contact)
            }
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
                    guard let prefixSection = self?.sections[indexPath.section] else {
                        return
                    }
                    
                    guard let prefixName = checkedContact.getName().uppercased().first else {
                        return
                    }
                    
                    if (prefixSection == prefixName) {
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        NotificationCenter.default.post(name: Notification.Name("changeContactName"), object: checkedContact)
                        return
                    }
                    
                    self?.deleteElement(indexPath: indexPath)
                }
                
                if (self?.mapContacts?.keys.contains(key) ?? false) {
                    self?.mapContacts?[key]?.append(checkedContact)
                    guard let section = self?.sections.firstIndex(of: key) else {
                        return
                    }
                    let indexSet = IndexSet.init(integersIn: 0...section)
                    self?.tableView.reloadSections(indexSet, with: .none)
                    
                } else {
                    
                    self?.mapContacts?[key] = [checkedContact]
                    self?.sections.append(key)
                    self?.sections.sort()
                    self?.tableView.reloadData()
                }
            }
        }
        return vc
        
    }
}
