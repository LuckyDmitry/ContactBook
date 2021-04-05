//
//  BirthdayNotificationService.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 4/4/21.
//

import Foundation

public protocol BirthdayServiceDelegate: class {
    
    func setNotification(forContact contact: Contact)
}

class BirthdayService {
 
    weak var delegate: BirthdayServiceDelegate?
    
    func birthdayNotification(contact: Contact) {
        delegate?.setNotification(forContact: contact)
    }
}
