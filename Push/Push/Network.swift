//
//  Network.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

fileprivate let publishKey = "demo-36"
fileprivate let subscribeKey = "demo-36"

class Network: NSObject, PNObjectEventListener {
    
    let configuration: PNConfiguration = {
        let config = PNConfiguration(publishKey: publishKey, subscribeKey: subscribeKey)
        return config
    }()
    
    var client: PubNub!
    
    static let sharedNetwork = Network()
    
    override init() {
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
