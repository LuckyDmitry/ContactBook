//
//  ErrorAlert.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 4/7/21.
//

import Foundation
import UIKit

protocol ErrorContactsDelegate: class {
    func showErrorAlert(msg: String, title: String)
}

public class ErrorContacts {
    var delegate: ErrorContactsDelegate?
}
