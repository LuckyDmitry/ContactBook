//
//  Contact.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/17/21.
//

import Foundation

public class Contact: Decodable, Encodable {
    
    private(set) var name: String = ""
    private(set) var surname: String = ""
    private(set) var phoneNumber: String = ""
    private(set) var email: String = ""
    private(set) var birthday: Date?
    private(set) var hash: Int64 = 0
    var builder = Builder()

    init () {
        builder.parent = self
    }
    
    public class Builder {
        
        var parent: Contact!
        
        public func set(name: String) -> Builder {
            parent.name = name
            return self
        }
        
        public func set(surname: String) -> Builder {
            parent.surname = surname
            return self
        }
        
        public func set(phone: String) -> Builder {
            parent.phoneNumber = phone
            return self
        }
        
        public func set(email: String) -> Builder {
            parent.email = email
            return self
        }
        
        public func set(hash: Int64) -> Builder {
            parent.hash = hash
            return self
        }
    
        public func set(birthday: Date) -> Builder {
            parent.birthday = birthday
            return self
        }
        
        public func build() -> Contact {
            if parent.hash == 0 {
                parent.hash = Int64(parent.strHash(UUID().uuidString))
            }
            return parent
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name = "firstname"
        case surname = "lastname"
        case phoneNumber = "phone"
        case email = "email"
    }
    
    private func strHash(_ str: String) -> UInt64 {
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
