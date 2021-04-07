import UIKit
import CoreData
import Gifu

class ContactCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var customView: CustomContactView!
    @IBOutlet var gifImageView: GIFImageView!
    
    override func prepareForReuse() {
        customView.setNeedsDisplay()
        gifImageView.prepareForReuse()
        super.prepareForReuse()
    }
}

class ContactTableViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate{
    
    @IBOutlet var searchBar: UISearchBar!
    private var mapContacts: Dictionary<Character, [Contact]> = [:]
    private var filteredContacts: [Contact] = []
    private var tableCellSections: [Character] = []
    @IBOutlet var tableView: UITableView!
    private var output: ContactsViewOutput!
    private var longPressGesture: UILongPressGestureRecognizer!
    private var isContactSearching: Bool = false
    
    @IBAction func onAddItemButtonPressed(_ sender: UIBarButtonItem) {
        output.addContactButtonPressed()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredContacts.removeAll()
        if searchText.isEmpty {
            isContactSearching = false
            tableView.reloadData()
            return
        }
        
        guard let firstLetter = searchText.first,
              let indexFirstLetter = tableCellSections.firstIndex(of: firstLetter) else {
            return
        }
        isContactSearching = true
        for contact in mapContacts[tableCellSections[indexFirstLetter]]!{
            let nameSurname = "\(contact.name.lowercased()) \(contact.surname.lowercased())"
            if nameSurname.starts(with: searchText.lowercased()) {
                filteredContacts.append(contact)
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        let presenter = ContactsPresenter()
        presenter.view = self
        searchBar.delegate = self
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
        if isContactSearching {
            return 1
        }
        return tableCellSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isContactSearching {
            return filteredContacts.count
        }
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
        
        var contact: Contact!
        if isContactSearching {
            contact = filteredContacts[indexPath.row]
        } else {
            contact = mapContacts[tableCellSections[indexPath.section]]?[indexPath.row]
        }
        
        if let myUrl = contact.photoUrl {
            cell.gifImageView.prepareForAnimation(withGIFURL: myUrl, loopCount: 100, completionHandler: nil)
            cell.gifImageView.startAnimatingGIF()
            cell.gifImageView.isHidden = false
            cell.customView.isHidden = true
        } else {
            cell.customView.isHidden = false
            cell.gifImageView.isHidden = true
            cell.customView.text = "\(contact.name.first ?? " ")\(contact.surname.first ?? " ")"
        }
        cell.nameLabel.text = "\(contact.name) \(contact.surname)"
        
        return cell
    }
}

extension ContactTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isContactSearching {
            return nil
        }
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
            if let url = contact.photoUrl {
                print(url)
            }
            return contact.name.uppercased().first ?? " "
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

