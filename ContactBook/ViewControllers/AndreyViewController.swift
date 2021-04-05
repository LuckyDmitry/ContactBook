//
//  AndreyViewController.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 4/3/21.
//

import UIKit

class AndreyViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var contact: Contact!
    @IBOutlet private var uiView: CustomContactView!
    private var isExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let contact = contact {
            
            guard let nameFirst = contact.name.first else {
                return
            }
            let text = "\(nameFirst)\(contact.surname.first ?? " ")"
            uiView.text = text
        }
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCustomView(recognizer:)))
        view.addSubview(uiView)
        uiView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
    }
    
    @objc func tapCustomView(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UITapGestureRecognizer.State.ended {
            UIView.animate(withDuration: 1.0, animations: {
                if self.isExpanded {
                    self.uiView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.isExpanded = false
                } else {
                    self.uiView.transform = CGAffineTransform(scaleX: 2, y: 2)
                    self.isExpanded = true
                }
            })
        }
    }
}
