//
//  RecentsRepository.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/26/21.
//

import Foundation

protocol RecentsRepository {
    
    func getCalls() throws -> [(Contact, Date)]
}
