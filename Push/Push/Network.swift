//
//  Network.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

fileprivate let DeviceTokenKey = "DeviceTokenKey"
fileprivate let publishKey = "pub-c-a9dc3f6b-98f7-4b44-97e6-4ea5a705ab2d"
fileprivate let subscribeKey = "sub-c-93f47f52-d6b4-11e6-9102-0619f8945a4f"

class Network: NSObject, PNObjectEventListener {
    
    let pushChannels: [String] = [String]()
    
    dynamic var deviceToken: Data? {
        didSet {
            UserDefaults.standard.set(deviceToken, forKey: DeviceTokenKey)
            guard let actualDeviceToken = deviceToken else {
                return
            }
            client.addPushNotificationsOnChannels(pushChannels, withDevicePushToken: actualDeviceToken) { (status) in
                print("\(status.debugDescription)")
            }
        }
    }
    
    let configuration: PNConfiguration = {
        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        return config
    }()
    
    var client: PubNub!
    
    static let sharedNetwork = Network()
    
    override init() {
        if let existingDeviceToken = UserDefaults.standard.object(forKey: DeviceTokenKey) {
            guard let actualDeviceToken = existingDeviceToken as? Data else {
                fatalError("What happened, we should have had: \(existingDeviceToken)")
            }
            self.deviceToken = actualDeviceToken
        }
        super.init()
        client = PubNub.clientWithConfiguration(configuration)
        client.addListener(self)
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
