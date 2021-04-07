//
//  CustomContactView.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 4/3/21.
//

import UIKit

class CustomContactView: UIView {

    var text: String = " "
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIGraphicsGetCurrentContext()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = CGFloat(rect.width - center.x)
        
        path?.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0;
        path?.setFillColor(CGColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1))
        path?.setLineWidth(5)
        path?.fillPath()
        path?.strokePath()
        
        let textRect = CGRect(x: center.x - (sqrt(2) / 2) * radius, y: center.y - (sqrt(2) / 2) * radius, width: 2 * (sqrt(2) / 2) * radius, height: 2 * (sqrt(2) / 2) * radius)
        
        let textToDwaw = NSString(string: text)
        textToDwaw.draw(in: textRect, withAttributes:
                            [NSAttributedString.Key.font: UIFont(name: "Helvetica Bold", size: radius / 1.1) as Any,
                     NSAttributedString.Key.foregroundColor: UIColor.randomColor()])
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
