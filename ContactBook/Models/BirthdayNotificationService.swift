//
//  BirthdayNotificationService.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 4/4/21.
//

import Foundation
import ContactsUI


class BirthdayService {
 
    
    func birthdayNotification(contact: Contact) {
        print(#function)
        
        guard let birthday = contact.birthday else {
            return
        }
        requestAuthorization()

        var calendar = Calendar.current.dateComponents([.day, .month], from: birthday)
        let currentDate = Date()
        var currentCalendar = Calendar.current.dateComponents([.minute, .hour], from: currentDate)
        currentCalendar.minute! += 1
        calendar.minute = currentCalendar.minute!
        calendar.hour = currentCalendar.hour
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Happy birthday"
        content.body = "Today birthday's \(contact.name) \(contact.surname)"
        
        let identifier = String(contact.hash)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func requestAuthorization() {
        print(#function)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (response, error) in
        }
    }
}
