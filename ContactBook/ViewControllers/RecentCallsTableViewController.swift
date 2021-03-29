import UIKit


class RecentCallTableCell: UITableViewCell {
    
    
    @IBOutlet var contactDetails: UILabel!
    @IBOutlet var dateOfCall: UILabel!
}

class RecentCallsTableViewController: UITableViewController {
    
    private var recentCalls: [(contact: Contact, date: Date)] = []
    private let recentRepository: RecentsRepository = CoreRecentsRepository()!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let workItem = DispatchWorkItem(qos: .userInitiated, block: {
            do {
               
                self.recentCalls = try self.recentRepository.getCalls()
            } catch {
                print(error.localizedDescription)
            }
        })
        workItem.notify(queue: .main) {
            self.tableView.reloadData()
        }
        
        DispatchQueue.global(qos: .userInitiated).async(execute: workItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recentCalls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCall", for: indexPath) as! RecentCallTableCell
        
        let name = recentCalls[indexPath.row].contact.name
        let surname = recentCalls[indexPath.row].contact.surname
        if (name.isEmpty && surname.isEmpty) {
            cell.contactDetails.text = recentCalls[indexPath.row].contact.phoneNumber
        } else {
            cell.contactDetails.text = name + " " + surname
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let date = formatter.string(from: recentCalls[indexPath.row].date)
        cell.dateOfCall.text = date
        return cell
    }
}
