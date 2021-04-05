//
//  CustomContactView.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 4/3/21.
//

import UIKit

class CustomContactView: UIView {

    var contact: Contact?
    
    override func draw(_ rect: CGRect) {
        let path = UIGraphicsGetCurrentContext()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = CGFloat(rect.width - center.x - 5)
        
        path?.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0;
        path?.setFillColor(CGColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1))
        path?.setLineWidth(5)
        path?.fillPath()
        path?.strokePath()

        let textRect = CGRect(x: center.x - (sqrt(2) / 2) * radius, y: center.y - (sqrt(2) / 2) * radius, width: 2 * (sqrt(2) / 2) * radius, height: 2 * (sqrt(2) / 2) * radius)
        
        if let contact = contact {
                
            guard let nameFirst = contact.name.first, let surnameFirst = contact.surname.first else {
                return
            }
            let contactIdentifier = String(nameFirst) + String(surnameFirst)
            
            print(contactIdentifier)
            let text = NSString(string: contactIdentifier)
            text.draw(in: textRect, withAttributes:
                        [NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: radius - 10) as Any,
                         NSAttributedString.Key.foregroundColor: UIColor.randomColor()])
        }
    }
}

extension UIColor {
    class func randomColor(randomAlpha: Bool = false) -> UIColor {
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let alphaValue = randomAlpha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1;

        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
    }
}
