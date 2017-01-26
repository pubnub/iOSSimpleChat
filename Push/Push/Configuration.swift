//
//  Configuration.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub
import CoreData

extension Network {
    
    var pubKeyString: String? {
        return client?.currentConfiguration().publishKey
    }
    
    var subKeyString: String? {
        return client?.currentConfiguration().subscribeKey
    }
    
    
}
