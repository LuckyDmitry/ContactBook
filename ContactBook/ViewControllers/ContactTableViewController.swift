import UIKit
import CoreData


class ContactCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var customView: CustomContactView!
    
    override func prepareForReuse() {
        customView.setNeedsDisplay()
        super.prepareForReuse()
    }
}

class ContactTableViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private var mapContacts: Dictionary<Character, [Contact]> = [:]
    private var tableCellSections: [Character] = []
    @IBOutlet var tableView: UITableView!
    private var output: ContactsViewOutput!
    private var longPressGesture: UILongPressGestureRecognizer!
    
    @IBAction func onAddItemButtonPressed(_ sender: UIBarButtonItem) {
        output.addContactButtonPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        let presenter = ContactsPresenter()
        presenter.view = self
        output = presenter
        
        let defaults = UserDefaults.standard
        var index = 1
        if let seletectedScreen = defaults.string(forKey: LauchScreenKey.launchKey),
            seletectedScreen == LaunchScreen.contactsScreen.rawValue {
            index = 0
        }
        self.tabBarController?.selectedIndex = index
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(recognizer:)))
        self.tableView.addGestureRecognizer(longPressGesture)
        longPressGesture.delegate = self
    }
    
    
    @objc func longPress(recognizer: UILongPressGestureRecognizer) {
        print(#function)
        if recognizer.state == UIGestureRecognizer.State.ended {
            let location = recognizer.location(in: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: location) {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "andreyViewController") as! AndreyViewController
                vc.contact = mapContacts[tableCellSections[indexPath.section]]?[indexPath.row]
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        output.viewWillLoad()
    }
}

extension ContactTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        guard let contact = mapContacts[tableCellSections[indexPath.section]]?[indexPath.row] else {
            return
        }
        output.contactPressed(contact: contact)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print(#function)
        if editingStyle == UITableViewCell.EditingStyle.delete {
            guard let contact = mapContacts[self.tableCellSections[indexPath.section]]?[indexPath.row] else {
                return
            }
            output.contactRemove(contact: contact)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableCellSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapContacts[tableCellSections[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
        if let contact = mapContacts[tableCellSections[indexPath.section]]?[indexPath.row] {
            cell.customView.text = "\(contact.name.first ?? " ")\(contact.surname.first ?? " ")"
            cell.nameLabel.text = "\(contact.name) \(contact.surname)"
        }
        return cell
    }
}

extension ContactTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(tableCellSections[section])
    }
}

extension ContactTableViewController {
    
    private func makeCall(idx: IndexPath) {
        print(#function)
        guard let contact = mapContacts[tableCellSections[idx.section]]?[idx.row] else {
            return
        }
        output.addCall(contact: contact, date: Date())
    }
}

extension ContactTableViewController: ContactsView {
    
    func showContacts(_ contacts: [Contact]) {
        print(#function)
        self.mapContacts = Dictionary(grouping: contacts){ contact in
            contact.name.uppercased().first ?? " "
        }
        
        self.tableCellSections.removeAll()
        
        for key in self.mapContacts.keys {
            self.tableCellSections.append(key)
        }
        
        self.tableCellSections.sort()
        
        self.tableCellSections.map({
            self.mapContacts[$0]?.sort(by: { (lhs, rhs) -> Bool in
                lhs.name < rhs.name
            })
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showContactView(_ viewController: UIViewController) {
        print(#function)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
