//
//  PublishInputAccessoryView.swift
//  Push
//
//  Created by Jordan Zucker on 2/7/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class PublishInputAccessoryView: UITextField {
    
    required init(target: Any, action: Selector, frame: CGRect) {
        super.init(frame: frame)
        borderStyle = .line
        backgroundColor = .green
        clearButtonMode = .whileEditing
        let publishFrame = CGRect(x: 0, y: 0, width: frame.width/5.0, height: frame.height)
        placeholder = "Enter message ..."
        let publishButton = UIButton(frame: publishFrame)
        //let publishButton = UIButton(type: .system)
        publishButton.setTitle("Publish", for: .normal)
        let normalImage = UIImage(color: .red, size: publishFrame.size)
        let highlightedImage = UIImage(color: .darkGray, size: publishFrame.size)
        publishButton.setBackgroundImage(normalImage, for: .normal)
        publishButton.setBackgroundImage(highlightedImage, for: .highlighted)
        publishButton.addTarget(target, action: action, for: .touchUpInside)
        rightView = publishButton
        rightViewMode = .unlessEditing
        returnKeyType = .send
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
