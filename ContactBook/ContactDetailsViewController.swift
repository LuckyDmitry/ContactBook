import UIKit

class ContactDetailsViewController: UIViewController {

    private var contact: Contact?
    private var mode: ContactMode
    private var rightButton: UIBarButtonItem!
    private var indexPath: IndexPath?

    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet var pickImageButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var phoneNumberTextField: UITextField!
    
    init(contactMode: ContactMode = ContactMode.Show, contact: Contact, indexPath: IndexPath? = nil){
        self.contact = contact
        self.mode = contactMode
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightButton = UIBarButtonItem(title: mode.getItemButton(), style: .done, target: self, action: #selector(buttonItemPressed))
        phoneNumberTextField.addTarget(self, action: #selector(makeCall), for: .touchDown)
        
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.title = mode.getTitleMode()
        surnameTextField?.text = contact?.getSurname()
        nameTextField?.text = contact?.getName()
        phoneNumberTextField?.text = contact?.getPhoneNumber()
        
        if (mode == ContactMode.Show) {
            changedMode(isActiveEditing: false)
        }
        else {
            changedMode(isActiveEditing: true)
        }
    }
    
    @IBAction func onPickImageViewButtonPressed() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
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
        if (mode == ContactMode.Add || mode == ContactMode.Edit) {
            
            guard let name = nameTextField?.text, let surname = surnameTextField?.text,
                  let phoneNumber = phoneNumberTextField?.text else {
                return
            }
            
            self.contact?.setNewName(name)
            self.contact?.setNewSurname(surname)
            self.contact?.setNewPhoneNumber(phoneNumber)
            competion?(self.contact, indexPath)
            navigationController?.popViewController(animated: true)
            
        } else if (mode == ContactMode.Show) {
            mode = ContactMode.Edit
            rightButton.title = mode.getItemButton()
            changedMode(isActiveEditing: true)
        }
    }
    
    public var competion: ((_ contact: Contact?, _ indexPath: IndexPath?) -> Void)?
    
    private func enableButtonOnTextFieldDifferent() {
        guard let name = nameTextField?.text, let surname = surnameTextField?.text,
              let phoneNumber = phoneNumberTextField?.text else {
            rightButton.isEnabled = false
            return
        }
        
        if (contact == nil) {
            contact = Contact("", "", "")
        } else if (name == "") {
            rightButton.isEnabled = false
        } else if (name != contact?.getName()) {
            rightButton.isEnabled = true
        } else if (surname != contact?.getSurname()) {
            rightButton.isEnabled = true
        } else if (phoneNumber != contact?.getPhoneNumber()) {
            rightButton.isEnabled = true
        } else if (imageView.image != nil){
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
        pickImageButton.isEnabled = isActiveEditing
    }
}

extension ContactDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            self.imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
