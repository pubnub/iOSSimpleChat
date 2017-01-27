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

extension UIAlertController {
    
    static func optionsAlertController(in context: NSManagedObjectContext, handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
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
        
        var isSubscribing = false
        context.performAndWait {
            isSubscribing = DataController.sharedController.fetchCurrentUser(in: context).isSubscribingToDebug
        }
        
        var isSubscribingTitle = "Subscribe to debug channels"
        if isSubscribing {
            isSubscribingTitle = "Stop subscribing to debug channels"
        }
        
        let subscribeToDebugAction = UIAlertAction(title: isSubscribingTitle, style: .default) { (action) in
            DataController.sharedController.performBackgroundTask({ (backgroundContext) in
                let user = DataController.sharedController.fetchCurrentUser(in: context)
                user.isSubscribingToDebug = (!user.isSubscribingToDebug)
                do {
                    try backgroundContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
                DispatchQueue.main.async {
                    handler?(action)
                }
            })
        }
        alertController.addAction(subscribeToDebugAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler?(action)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}
