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
    
    let stackView = UIStackView(frame: .zero)
    let publishButton = UIButton(type: .custom)
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
        let spacing = CGFloat(integerLiteral: 5)
        backgroundColor = .darkGray
        addSubview(stackView)
        stackView.forceAutoLayout()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = spacing
        stackView.addArrangedSubview(textField)
        stackView.layoutMargins = UIEdgeInsetsMake(spacing, spacing, spacing, spacing)
        stackView.isLayoutMarginsRelativeArrangement = true
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.clearButtonMode = .whileEditing
        let publishFrame = CGRect(x: 0, y: 0, width: frame.width/5.0, height: frame.height)
        textField.placeholder = "Tap here to type a message ..."
        publishButton.forceAutoLayout()
        publishButton.setTitle("Publish", for: .normal)
        publishButton.setTitleColor(.black, for: .normal)
        publishButton.layer.cornerRadius = 5.0
        publishButton.layer.masksToBounds = true
        let normalImage = UIImage(color: .cyan, size: publishFrame.size)
        let highlightedImage = UIImage(color: .lightGray, size: publishFrame.size)
        publishButton.setBackgroundImage(normalImage, for: .normal)
        publishButton.setBackgroundImage(highlightedImage, for: .highlighted)
        publishButton.addTarget(target, action: action, for: .touchUpInside)
        textField.adjustsFontSizeToFitWidth = true
        textField.clearButtonMode = .always
        textField.returnKeyType = .send
        textField.forceAutoLayout()
        stackView.addArrangedSubview(publishButton)
        stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.75).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
