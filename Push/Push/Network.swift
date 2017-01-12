//
//  Network.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData
import PubNub

fileprivate let DeviceTokenKey = "DeviceTokenKey"
fileprivate let publishKey = "pub-c-a9dc3f6b-98f7-4b44-97e6-4ea5a705ab2d"
fileprivate let subscribeKey = "sub-c-93f47f52-d6b4-11e6-9102-0619f8945a4f"

class Network: NSObject, PNObjectEventListener {
    
//    var pushChannels: [String] = [String]()
    
//    dynamic var deviceToken: Data? {
//        didSet {
//            UserDefaults.standard.set(deviceToken, forKey: DeviceTokenKey)
//            guard let actualDeviceToken = deviceToken else {
//                return
//            }
//            client.addPushNotificationsOnChannels(pushChannels, withDevicePushToken: actualDeviceToken) { (status) in
//                print("\(status.debugDescription)")
//                DataController.sharedController.persistentContainer.performBackgroundTask({ (context) in
//                    let _ = ResultType.createCoreDataObject(result: status, in: context)
//                    do {
//                        try context.save()
//                    } catch {
//                        fatalError(error.localizedDescription)
//                    }
//                })
//                
//            }
//        }
//    }
//    var deviceToken: Data?
    
//    let configuration: PNConfiguration = {
//        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
//        config.uuid = User.userID
//        return config
//    }()
    
    private var networkKVOContext = 0
    
    func config(with identifier: String) -> PNConfiguration {
        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        config.uuid = identifier
        return config
    }
    
    var client: PubNub!
    private var user: User? {
        didSet {
            if let existingOldValue = oldValue {
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushToken), context: &networkKVOContext)
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushChannels), context: &networkKVOContext)
            }
            user?.addObserver(self, forKeyPath: #keyPath(User.pushToken), options: [.new, .old, .initial], context: &networkKVOContext)
            user?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &networkKVOContext)
        }
    }
    
    deinit {
        user = nil
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &networkKVOContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(User.pushToken):
                print("Update name")
                print("object: \(object.debugDescription)")
                print("change: \(change)")
                let _ = change![NSKeyValueChangeKey.newKey] as? Data
                print("KVO \(keyPath)")
                // now remove old and add new
            case #keyPath(User.pushChannels):
                print("Update all media")
                print("object: \(object.debugDescription)")
                print("change: \(change)")
                print("KVO \(keyPath)")
                guard let _ = change![NSKeyValueChangeKey.newKey] as? Set<Channel> else {
                    return // no changes
                }
                // now updated added channels
            default:
                fatalError("what wrong in KVO?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    let networkContext: NSManagedObjectContext
    
    static let sharedNetwork = Network()
    
    func setUp() {
        // Should this be nested? It seems fishy
        networkContext.perform {
            self.user = DataController.sharedController.currentUser(in: self.networkContext)
            let configuration = self.config(with: self.user!.identifier!)
            self.client = PubNub.clientWithConfiguration(configuration)
            self.client.addListener(self)
        }
    }
    
    
    override init() {
//        if let existingDeviceToken = UserDefaults.standard.object(forKey: DeviceTokenKey) {
//            guard let actualDeviceToken = existingDeviceToken as? Data else {
//                fatalError("What happened, we should have had: \(existingDeviceToken)")
//            }
//            self.deviceToken = actualDeviceToken
//        }
        self.networkContext = DataController.sharedController.persistentContainer.newBackgroundContext()
        super.init()
//        client = PubNub.clientWithConfiguration(configuration)
//        client.addListener(self)
//        // add a channel here
//        pushChannels.append("a")
    }
    
    // MARK: - PNObjectEventListener
    
    func client(_ client: PubNub, didReceive status: PNStatus) {
        print("\(#function) status: \(status.debugDescription)")
    }
    
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        print("\(#function) message: \(message.debugDescription)")
    }
    
    func client(_ client: PubNub, didReceivePresenceEvent event: PNPresenceEventResult) {
        print("\(#function) event: \(event.debugDescription)")
    }

}
