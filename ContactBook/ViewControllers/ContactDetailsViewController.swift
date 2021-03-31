import UIKit

class ContactDetailsViewController: UIViewController {

    private var contact: Contact?
    private var mode: ContactMode
    private var rightButton: UIBarButtonItem!

    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet var phoneNumberTextField: UITextField!
    
    init(contactMode: ContactMode = ContactMode.show, contact: Contact){
        self.contact = contact
        self.mode = contactMode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var competion: ((_ contact: Contact?, _ mode: ContactMode?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightButton = UIBarButtonItem(title: mode.getItemButton(), style: .done, target: self, action: #selector(buttonItemPressed))
        phoneNumberTextField.addTarget(self, action: #selector(makeCall), for: .touchDown)
        
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.title = mode.rawValue
        surnameTextField?.text = contact?.surname
        nameTextField?.text = contact?.name
        phoneNumberTextField?.text = contact?.phoneNumber
        
        if (mode == ContactMode.show) {
            changedMode(isActiveEditing: false)
        }
        else {
            changedMode(isActiveEditing: true)
        }
    }
    
    @IBAction func onNameTextFieldChanged(_ sender: UITextField) {
        enableButtonOnTextFieldDifferent()
    }
    
    @IBAction func onPhoneNumberTextFieldChanged() {
        enableButtonOnTextFieldDifferent()
    }
    
    @IBAction func onSurnameTextFieldChanged(_ sender: UITextField) {
        enableButtonOnTextFieldDifferent()
    }
    
    @objc func makeCall() {
        print("here")
    }
    
    @objc func buttonItemPressed() {
        if (mode == ContactMode.add || mode == ContactMode.edit) {
            
            guard let name = nameTextField?.text, let surname = surnameTextField?.text,
                  let phoneNumber = phoneNumberTextField?.text else {
                return
            }
            
            contact?.name = name
            contact?.surname = surname
            contact?.phoneNumber = phoneNumber
            competion?(contact, mode)
            navigationController?.popViewController(animated: true)
            
        } else if (mode == ContactMode.show) {
            mode = ContactMode.edit
            navigationItem.title = mode.rawValue
            rightButton.title = mode.getItemButton()
            changedMode(isActiveEditing: true)
        }
    }
    
    private func enableButtonOnTextFieldDifferent() {
        guard let name = nameTextField?.text, let surname = surnameTextField?.text,
              let phoneNumber = phoneNumberTextField?.text else {
            rightButton.isEnabled = false
            return
        }
        
        if (contact == nil) {
            contact = Contact(contactName: "", contactSurname: "", number: "", email: "")
        } else if (name == "") {
            rightButton.isEnabled = false
        } else if (name != contact?.name) {
            rightButton.isEnabled = true
        } else if (surname != contact?.surname) {
            rightButton.isEnabled = true
        } else if (phoneNumber != contact?.phoneNumber) {
            rightButton.isEnabled = true
        } else {
            rightButton.isEnabled = false
        }
    }
    
    private func changedMode(isActiveEditing: Bool) {
        surnameTextField.isEnabled = isActiveEditing
        nameTextField.isEnabled = isActiveEditing
        phoneNumberTextField.isEnabled = isActiveEditing
        rightButton.isEnabled = !isActiveEditing
        
    }
}
