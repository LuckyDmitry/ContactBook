//
//  SceneDelegate.swift
//  ContactBook
//
//  Created by Trifonov Dmitry on 3/17/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, ErrorContactsDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func showErrorAlert(msg: String, title: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
            self?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

