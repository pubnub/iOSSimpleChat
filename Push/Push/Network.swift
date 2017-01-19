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
    
    func setCurrentUser(user: User?) {
        guard let actualUser = user else {
            DispatchQueue.main.async {
                self.user = nil
            }
            return
        }
        DispatchQueue.main.async {
            guard let contextualUser = self.networkContext.object(with: actualUser.objectID) as? User else {
                fatalError()
            }
            self.user = contextualUser
        }
    }
    
    
    private var user: User? {
        didSet {
            if let existingOldValue = oldValue {
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushToken), context: &networkKVOContext)
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushChannels), context: &networkKVOContext)
            }
            user?.addObserver(self, forKeyPath: #keyPath(User.pushToken), options: [.new, .old, .initial], context: &networkKVOContext)
            user?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &networkKVOContext)
            guard let currentUser = user else {
                return
            }
            networkContext.perform {
                let identifier = currentUser.identifier!
                DispatchQueue.main.async {
                    let configuration = self.config(with: identifier)
                    self.client = PubNub.clientWithConfiguration(configuration)
                    self.client.addListener(self)
                }
            }
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
                networkContext.perform {
                    let currentPushToken = currentUser.pushToken
                    DispatchQueue.main.async {
                        self.pushToken = currentPushToken
                    }
                }
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
    
    
    override init() {
        let context = DataController.sharedController.persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        self.networkContext = context
        super.init()
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
        print("%%%%%%%%%%%%%%%% \(#function) with old: \(oldChannels) and new: \(newChannels)")
    }
    
    func updatePushToken(oldToken: Data?, newToken: Data?) {
        
    }
    
    func channelsArray(for set: Set<String>?) -> [String]? {
        guard let actualSet = set else {
            return nil
        }
        return actualSet.map { (channelName) -> String in
            return channelName
        }
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
