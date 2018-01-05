//
//  ReachabilityErrorAlert.swift
//  VirtualTourist
//
//  Created by Noureddine Marigh on 12/25/17.
//  Copyright © 2018 NM. All rights reserved.
//

import UIKit
extension UIViewController {
    func noInternetAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
