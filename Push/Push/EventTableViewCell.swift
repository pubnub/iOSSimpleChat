//
//  EventTableViewCell.swift
//  Push
//
//  Created by Jordan Zucker on 1/23/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import CoreData

class EventTableViewCell: UITableViewCell {

    let textView: UITextView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.textView = UITextView(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textView.forceAutoLayout()
        textView.isEditable = false
        textView.isScrollEnabled = false
        contentView.addSubview(textView)
        let widthConstraint = NSLayoutConstraint(item: textView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: textView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: textView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with object: NSManagedObject) {
        guard let event = object as? Event else {
            fatalError("Failed to convert: \(object.debugDescription)")
        }
        textView.text = event.textViewDisplayText
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
    }

}
