//
//  SettingsViewController.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/24/21.
//

import UIKit

public enum LauchScreenKey {
    public static let launchKey = "com.trifonov.contactBook"
}

enum LaunchScreen: String {
    case contactsScreen
    case callHistoryScreen
}

class SettingsViewController: UIViewController {
    
    private enum Fonts: String {
        case sanFrancisco = "SanFranciscoText-Light"
    }

    private var pickerView: UIPickerView!
    private var textLabel: UILabel!
    private var content = [LaunchScreen.contactsScreen, LaunchScreen.callHistoryScreen]
    private var selectedItem: Int = 0
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        textLabel.text = "Choose settings screen to show when app launches"
        textLabel.numberOfLines = 2
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pickerView = UIPickerView(frame: CGRect(x: 0 , y: 0, width: 200, height: 200))
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        view.addSubview(textLabel)
        
        textLabel.bottomAnchor.constraint(equalTo: pickerView.topAnchor).isActive = true
        textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        let selectedRow = defaults.string(forKey: LauchScreenKey.launchKey)
        let idx = content.firstIndex(where: {$0.rawValue == selectedRow}) ?? 1
        pickerView?.selectRow(idx, inComponent: 0, animated: true)
    }
}

extension SettingsViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: Fonts.sanFrancisco.rawValue, size: 18)
        label.text = content[row].rawValue
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaults.setValue(content[row].rawValue, forKey: LauchScreenKey.launchKey)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
        return content[row].rawValue
    }
}

extension SettingsViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        content.count
    }
}
