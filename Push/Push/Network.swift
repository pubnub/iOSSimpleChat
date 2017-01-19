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
//            guard let currentUser = user else {
//                return
//            }
//            networkContext.perform {
//                self.networkContext.refresh(currentUser, mergeChanges: true)
//                let configuration = self.config(with: currentUser.identifier!)
//                self.client = PubNub.clientWithConfiguration(configuration)
//                self.client.addListener(self)
//            }
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
            guard let currentUser = object as? User else {
                fatalError("How is it not a user: \(object.debugDescription)")
            }
            switch existingKeyPath {
            case #keyPath(User.pushToken):
//                print("Network: Push Token KVO")
//                print("Network: object: \(object.debugDescription)")
//                print("Network: change: \(change)")
//                let _ = change![NSKeyValueChangeKey.newKey] as? Data
//                print("Network: KVO \(keyPath)")
                // now remove old and add new
                networkContext.perform {
                    let currentPushToken = currentUser.pushToken
                    DispatchQueue.main.async {
                        self.pushToken = currentPushToken
                    }
                }
//                self.pushToken = object as? Data // check this!!!!!
            case #keyPath(User.pushChannels):
                networkContext.perform {
                    let newChannels = currentUser.pushChannels?.map({ (channel) -> String in
                        return channel.name!
                    })
                    var finalResult: Set<String>? = nil
                    if let actualChannels = newChannels {
                        finalResult = Set(actualChannels)
                    }
                    DispatchQueue.main.async {
                        self.pushChannels = finalResult
                    }
                }
                
                // now updated added channels
            default:
                fatalError("what wrong in KVO?")
            }
            print("======================================")
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    let networkContext: NSManagedObjectContext
    
    static let sharedNetwork = Network()
    
    func setUp() {
        // Should this be nested? It seems fishy
//        let viewContext = DataController.sharedController.persistentContainer.viewContext
//        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(notification:)), name: .NSManagedObjectContextObjectsDidChange, object: viewContext)
//        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidSave(notification:)), name: .NSManagedObjectContextDidSave, object: viewContext)
        networkContext.perform {
//            guard let currentUser = self.networkContext.object(with: user.objectID) as? User else {
//                fatalError("How did we not find a user for \(user.debugDescription)")
//            }
//            self.user = currentUser
//            guard let currentUser = DataController.sharedController.fetchCurrentUser(in: self.networkContext) else {
//                fatalError("How did we not find a user for user: \(user.debugDescription)")
//            }
//            self.user = currentUser
            
            self.user = DataController.sharedController.fetchCurrentUser(in: self.networkContext)
//            let configuration = self.config(with: self.user!.identifier!)
//            self.client = PubNub.clientWithConfiguration(configuration)
//            self.client.addListener(self)
        }
    }
    
    
    override init() {
//        if let existingDeviceToken = UserDefaults.standard.object(forKey: DeviceTokenKey) {
//            guard let actualDeviceToken = existingDeviceToken as? Data else {
//                fatalError("What happened, we should have had: \(existingDeviceToken)")
//            }
//            self.deviceToken = actualDeviceToken
//        }
        let context = DataController.sharedController.persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        self.networkContext = context
        super.init()
//        client = PubNub.clientWithConfiguration(configuration)
//        client.addListener(self)
//        // add a channel here
//        pushChannels.append("a")
    }
    
    // MARK: - APNS
    
    var pushToken: Data? {
        didSet {
            print("set pushToken: \(pushToken)")
            // now remove old token and update new token
            updatePushToken(oldToken: oldValue, newToken: pushToken)
        }
    }
    
    var pushChannels: Set<String>? = Set() {
        didSet {
            updatePush(oldChannels: oldValue, newChannels: pushChannels)
        }
    }
    
    func updatePush(oldChannels: Set<String>?, newChannels: Set<String>?) {
//        networkContext.perform {
//            let currentPushChannels = self.user?.pushChannels
//            let updatedArray: [Channel] = newChannels.map({ (channel) -> Channel in
//                return self.networkContext.object(with: channel.objectID) as! Channel
//            })
//            let updatedSet: Set<Channel> = Set(updatedArray)
//            
//        }
        print("%%%%%%%%%%%%%%%% \(#function) with old: \(oldChannels) and new: \(newChannels)")
    }
    
    func updatePushToken(oldToken: Data?, newToken: Data?) {
//        networkContext.perform {
//            let currentPushToken = self.user?.pushToken
//            DispatchQueue.main.async {
//                self.pushToken = currentPushToken
//            }
//        }
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
