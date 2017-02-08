//
//  PublishInputAccessoryView.swift
//  Push
//
//  Created by Jordan Zucker on 2/7/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

class PublishInputAccessoryView: UIView {
    
    weak var delegate: UITextFieldDelegate? {
        didSet {
            textField.delegate = delegate
        }
    }
    
    let textField = UITextField(frame: .zero)
    
    var text: String? {
        set {
            textField.text = newValue
        }
        get {
            return textField.text
        }
    }
    
    override func resignFirstResponder() -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var canResignFirstResponder: Bool {
        return false
    }
    
    required init(target: Any, action: Selector, frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        addSubview(textField)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.clearButtonMode = .whileEditing
        let publishFrame = CGRect(x: 0, y: 0, width: frame.width/5.0, height: frame.height)
        textField.placeholder = "Enter message ..."
        let publishButton = UIButton(frame: publishFrame)
        //let publishButton = UIButton(type: .system)
        publishButton.setTitle("Publish", for: .normal)
        let normalImage = UIImage(color: .red, size: publishFrame.size)
        let highlightedImage = UIImage(color: .darkGray, size: publishFrame.size)
        publishButton.setBackgroundImage(normalImage, for: .normal)
        publishButton.setBackgroundImage(highlightedImage, for: .highlighted)
        publishButton.addTarget(target, action: action, for: .touchUpInside)
        textField.rightView = publishButton
        textField.rightViewMode = .unlessEditing
        textField.returnKeyType = .send
        textField.forceAutoLayout()
        textField.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        textField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
