//
//  PushNotifications.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class PushNotifications: NSObject, UNUserNotificationCenterDelegate {
    
    static let sharedNotifications = PushNotifications()
    
    let pushContext: NSManagedObjectContext
    
    override init() {
        self.pushContext = DataController.sharedController.newBackgroundContext()
        super.init()
        pushContext.automaticallyMergesChangesFromParent = true
    }
    
    func clearBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func appDidLaunchOperations(viewController: UIViewController? = nil) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            // This means we have not yet asked for notification permissions
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                    // You might want to remove this, or handle errors differently in production
                    assert(error == nil)
                    if granted {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                })
            // We are already authorized, so no need to ask
            case .authorized:
                // Just try and register for remote notifications
                UIApplication.shared.registerForRemoteNotifications()
            case .denied:
                // Possibly display something to the user
                let useNotificationsAlertController = UIAlertController(title: "Turn on notifications", message: "This app needs notifications turned on for the best user experience", preferredStyle: .alert)
                let goToSettingsAction = UIAlertAction(title: "Go to settings", style: .default, handler: { (action) in
                    
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .default)
                useNotificationsAlertController.addAction(goToSettingsAction)
                useNotificationsAlertController.addAction(cancelAction)
                viewController?.present(useNotificationsAlertController, animated: true)
                print("We cannot use notifications because the user has denied permissions")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("\(#function) notification: \(notification.debugDescription)")
        pushContext.perform {
            let _ = DataController.sharedController.createCoreDataEvent(in: self.pushContext, for: notification, with: DataController.sharedController.fetchCurrentUser(in: self.pushContext))
            do {
                try self.pushContext.save()
                DispatchQueue.main.async {
                    completionHandler([.alert, .sound, .badge])
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("\(#function) response: \(response.debugDescription)")
    }

}
