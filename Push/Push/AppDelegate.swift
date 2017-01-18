//
//  AppDelegate.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let viewContext = DataController.sharedController.persistentContainer.viewContext
        let userID = User.userID
        if let currentUser = User.user(for: userID, in: viewContext) {
            DataController.sharedController.currentUserObjectID = currentUser.objectID
        } else {
            viewContext.performAndWait {
                let user = User(context: viewContext)
                user.identifier = userID
                DataController.sharedController.currentUserObjectID = user.objectID
                do {
                    try viewContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
//        guard let currentUser = User.user(for: userID, in: viewContext) else {
//            fatalError("Couldn't find user for ID: \(userID)")
//        }
//        viewContext.performAndWait {
//            let user = User(context: viewContext)
//            user.identifier = User.userID
//            do {
//                try viewContext.save()
//            } catch {
//                fatalError("What now?")
//            }
//            DataController.sharedController.currentUserObjectID = user.objectID
////            Network.sharedNetwork.setUp()
//        }
//        DataController.sharedController.persistentContainer.performBackgroundTask { (context) in
//            context.perform {
//                let user = User(context: context)
//                user.identifier = User.userID
//                DataController.sharedController.currentUserObjectID = user.objectID
//                Network.sharedNetwork.setUp()
//                do {
//                    try context.save()
//                } catch {
//                    fatalError("What now?")
//                }
//                
//            }
//        }
        
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
                self.window?.rootViewController?.present(useNotificationsAlertController, animated: true)
                print("We cannot use notifications because the user has denied permissions")
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        let bounds = UIScreen.main.bounds
        let window = UIWindow(frame: bounds)
        self.window = window
        
        let rootViewController = MainViewController()
        rootViewController.currentUser = DataController.sharedController.currentUser()
        print("Current user ID: \(DataController.sharedController.currentUser().identifier!)")
        let navController = UINavigationController(rootViewController: rootViewController)
        
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        DataController.sharedController.saveContext()
    }
    
    // MARK: - Remote Notifications
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Sometimes it’s useful to store the device token in UserDefaults
//        UserDefaults.standard.set(deviceToken, forKey: "DeviceToken")
//        Network.sharedNetwork.client.addPushNotificationsOnChannels(["a"], withDevicePushToken: deviceToken) { (status) in
//            print("add push: \(status.debugDescription)")
//        }
//        Network.sharedNetwork.deviceToken = deviceToken
        DataController.sharedController.persistentContainer.performBackgroundTask { (context) in
            print("background task")
            let currentUser = DataController.sharedController.currentUser(in: context)
            print("received push token: \(deviceToken.debugDescription)")
            currentUser.pushToken = deviceToken
            do {
                try context.save()
            } catch {
                fatalError("What went wrong now??")
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFail! with error: \(error)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("\(#function) notification: \(notification.debugDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("\(#function) response: \(response.debugDescription)")
    }
    

}

