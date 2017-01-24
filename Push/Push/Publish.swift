//
//  Publish.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub
import CoreData

extension Network {
    
    func publishAlertController(handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: "Publish Message to PubNub", message: "Configure the message then click publish below", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Channels ..."
        }
        
        let channelsTextField = alertController.textFields![0]
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter message payload ..."
            textField.text = "Hello, world!"
        }
        
        let payloadTextField = alertController.textFields![1]
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter mobile push dictionary"
            textField.text = "{\"pn_apns\": {\"aps\": {\"alert\": \"Your order is ready for pickup!\",\"badge\": 1,\"payment_info\": {\"credit_card\": 987656789876,\"expiration\": \"0108\"}}},\"pn_gcm\": {\"data\": \"this is my data only for gcm devices\"},\"data_for_all\": {\"info\": \"This is data all non-APNS and non-GCM devices would receive. They would also receive the pn_apns and pn_gcm data.\"}}"
        }
        
        let pushPayloadTextField = alertController.textFields![2]
        
        var finalPushPayload: [String:Any]? = nil
        if let pushPayloadData = pushPayloadTextField.text?.data(using: .utf8) {
            do {
                finalPushPayload = try JSONSerialization.jsonObject(with: pushPayloadData, options: [.allowFragments]) as? [String: Any]
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
        let publishAction = UIAlertAction(title: "Publish", style: .destructive) { (action) in
            self.client.publish(payloadTextField.text, toChannel: channelsTextField.text!, mobilePushPayload: finalPushPayload, withCompletion: { (status) in
                self.networkContext.perform {
                    let _ = DataController.sharedController.createCoreDataEvent(in: self.networkContext, for: status, with: self.user)
                    do {
                        try self.networkContext.save()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            })
            handler?(action)
        }
        alertController.addAction(publishAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            handler?(action)
        }
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
}
