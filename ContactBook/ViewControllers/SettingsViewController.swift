//
//  SettingsViewController.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/24/21.
//

import UIKit


enum SettingOfRequestMethod: String {
    case manualParsingApproach
    case enumParsingApproach
    case enumParsingApproachWithDispatchWorkItem
    case withOperationQueue
    
    case settingKey = "keyOfSettingRequest"
    
    public static func chooseSettings(row: Int) -> SettingOfRequestMethod {
        switch row {
        case 1:
            return SettingOfRequestMethod.enumParsingApproach
        case 2:
            return SettingOfRequestMethod.enumParsingApproachWithDispatchWorkItem
        case 3:
            return SettingOfRequestMethod.withOperationQueue
        default:
            return SettingOfRequestMethod.manualParsingApproach
        }
    }
}

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private var pickerView: UIPickerView!
    private let content = ["manualParsingApproach", "enumParsingApproach", "enumParsingApproachWithDispatchWorkItem", "withOperationQueue"]
    private var selectedItem: Int = 0
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView = UIPickerView(frame: CGRect(x: 0 , y: 0, width: 200, height: 200))
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)

        pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        let row = defaults.integer(forKey: SettingOfRequestMethod.settingKey.rawValue)
        if row != 0 {
            pickerView?.selectRow(row, inComponent: 0, animated: true)
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()

            label.textColor = .black
            label.textAlignment = .center
            label.font = UIFont(name: "SanFranciscoText-Light", size: 18)

            // where data is an Array of String
            label.text = content[row]

            return label
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        content.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
        return content[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaults.setValue(row, forKey: SettingOfRequestMethod.settingKey.rawValue)
    }
}

