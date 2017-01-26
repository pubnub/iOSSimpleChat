//
//  Options.swift
//  Push
//
//  Created by Jordan Zucker on 1/25/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import IdleTimer

extension UIAlertController {
    
    static func optionsAlertController(handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Options", message: "Choose an option", preferredStyle: .actionSheet)
        
        let clearConsoleAction = UIAlertAction(title: "Clear console", style: .destructive) { (action) in
            DataController.sharedController.resetResultsForCurrentUser {
                handler?(action)
            }
        }
        alertController.addAction(clearConsoleAction)
        
        let oppositeScreenStateTitle = IdleTimer.sharedInstance.screenState.oppositeState.title
        let screenStateActionTitle = "Turn idle timer \(oppositeScreenStateTitle)"
        let screenStateAction = UIAlertAction(title: screenStateActionTitle, style: .default) { (action) in
            let _ = IdleTimer.sharedInstance.switchScreenState()
            handler?(action)
        }
        alertController.addAction(screenStateAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler?(action)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}
