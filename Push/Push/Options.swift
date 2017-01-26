//
//  Options.swift
//  Push
//
//  Created by Jordan Zucker on 1/25/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func optionsAlertController(handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Options", message: "Choose an option", preferredStyle: .actionSheet)
        
        let clearConsoleAction = UIAlertAction(title: "Clear console", style: .destructive) { (action) in
            DataController.sharedController.resetResultsForCurrentUser {
                handler?(action)
            }
        }
        alertController.addAction(clearConsoleAction)
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler?(action)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}
