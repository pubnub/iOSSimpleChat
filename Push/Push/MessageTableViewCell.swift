//
//  MessageTableViewCell.swift
//  Push
//
//  Created by Jordan Zucker on 2/7/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

struct MessageCellUpdate {
    let name: String
    let image: UIImage?
    let message: String?
    let isSelf: Bool
    
    init(name: String, image: UIImage?, message: String?, isSelf: Bool = false) {
        self.name = name
        self.image = image
        self.message = message
        self.isSelf = isSelf
    }
}

class MessageTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.fakeClear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with update: MessageCellUpdate) {
        imageView?.image = update.image
        imageView?.layer.masksToBounds = true
        imageView?.layer.cornerRadius = 5.0
        textLabel?.text = update.message
        detailTextLabel?.text = "from \(update.name)"
        detailTextLabel?.isHidden = false
        setNeedsLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
        textLabel?.text = nil
        detailTextLabel?.text = nil
    }

}
