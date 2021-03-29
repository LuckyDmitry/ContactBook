//
//  Contact.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/17/21.
//

import Foundation

public class Contact: Decodable {
    
    var name: String
    var surname: String
    var phoneNumber: String
    var email: String
    private(set) var hash: Int64 = 0

    init (contactName: String, contactSurname: String, number: String, email: String, oldHash: Int64? = nil) {
        self.name = contactName
        self.surname = contactSurname
        self.phoneNumber = number
        self.email = email
        self.hash = oldHash ?? Int64(strHash(UUID().uuidString))
    }
    
    private enum CodingKeys: String, CodingKey {
        case name = "firstname"
        case surname = "lastname"
        case phoneNumber = "phone"
        case email = "email"
    }
    
    func strHash(_ str: String) -> UInt64 {
        var result = UInt64 (5381)
        let buf = [UInt8](str.utf8)
        for b in buf {
            result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
        }
        return result
    }
}

extension Contact: Equatable {
    public static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name == rhs.name &&
                lhs.surname == rhs.surname &&
                lhs.phoneNumber == rhs.phoneNumber &&
                lhs.email == rhs.email
    }
}
