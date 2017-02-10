//
//  Options.swift
//  Push
//
//  Created by Jordan Zucker on 1/25/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData
import IdleTimer

extension IdleTimer {
    var optionsTitleForCurrentScreenState: String {
        switch screenState {
        case .awake:
            return "Let screen sleep when idle"
        case .sleepy:
            return "Keep screen awake"
        }
    }
}

extension UIAlertController {
    
    static func optionsAlertController(in context: NSManagedObjectContext, handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Options", message: "Choose an option", preferredStyle: .actionSheet)
        
        let clearConsoleAction = UIAlertAction(title: "Clear console", style: .destructive) { (action) in
            DataController.sharedController.resetResultsForCurrentUser {
                handler?(action)
            }
        }
        alertController.addAction(clearConsoleAction)
        
        let screenStateActionTitle = IdleTimer.sharedInstance.optionsTitleForCurrentScreenState
        let screenStateAction = UIAlertAction(title: screenStateActionTitle, style: .default) { (action) in
            _ = IdleTimer.sharedInstance.switchScreenState()
            handler?(action)
        }
        alertController.addAction(screenStateAction)
        
        let learnMoreAboutPubNubAction = UIAlertAction(title: "Learn more about PubNub", style: .default) { (action) in
            guard let pubNubURL = URL(string: "https://www.pubnub.com/") else {
                return
            }
            UIApplication.shared.open(pubNubURL, options: [:], completionHandler: { (_) in
                handler?(action)
            })
        }
        alertController.addAction(learnMoreAboutPubNubAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler?(action)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}
