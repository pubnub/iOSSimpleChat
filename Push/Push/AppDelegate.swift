//
//  AppDelegate.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import UserNotifications
import IdleTimer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("Current screen state: \(IdleTimer.sharedInstance.screenState.title)")
        let viewContext = DataController.sharedController.viewContext
        let userID = User.userID
        var shouldForceProfileView = false
        if let currentUser = DataController.sharedController.fetchUser(for: userID, in: viewContext) {
            DataController.sharedController.currentUser = currentUser
            viewContext.performAndWait {
                if currentUser.name == nil {
                    shouldForceProfileView = true
                }
            }
        } else {
            shouldForceProfileView = true
            viewContext.performAndWait {
                let user = User(context: viewContext)
                user.identifier = userID
                do {
                    try viewContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
                DataController.sharedController.currentUser = user
            }
        }
        
        let bounds = UIScreen.main.bounds
        let window = UIWindow(frame: bounds)
        self.window = window
        
        let rootViewController = MainViewController()
        let navController = UINavigationController(rootViewController: rootViewController)
        
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        if shouldForceProfileView {
            let profileViewController = ProfileViewController()
            profileViewController.canSave = false
            profileViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: profileViewController, action: #selector(ProfileViewController.dismiss(sender:)))
            let profileNavController = UINavigationController(rootViewController: profileViewController)
            profileNavController.modalTransitionStyle = .coverVertical
            profileNavController.modalPresentationStyle = .overFullScreen
            rootViewController.present(profileNavController, animated: true)
        }
        
        PushNotifications.sharedNotifications.appDidLaunchOperations(viewController: self.window?.rootViewController)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        Network.sharedNetwork.updateSubscription(with: .unsubscribe)
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
        Network.sharedNetwork.updateSubscription(with: .subscribe)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        Network.sharedNetwork.updateSubscription(with: .unsubscribe)
        DataController.sharedController.save()
    }
    
    // MARK: - Remote Notifications
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DataController.sharedController.performBackgroundTask { (context) in
            let currentUser = DataController.sharedController.fetchCurrentUser(in: context)
            currentUser.pushToken = deviceToken
            do {
                try context.save()
            } catch {
                fatalError("What went wrong now??")
            }
        }
    }

}

