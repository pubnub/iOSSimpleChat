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
    var isSelf: Bool
    let stackView: UIStackView = {
        let cellStackView = UIStackView(frame: .zero)
        cellStackView.axis = .horizontal
        cellStackView.alignment = .center
        cellStackView.distribution = .fill
        return cellStackView
    } ()
    
    init(name: String, image: UIImage?, message: String?, isSelf: Bool = false) {
        self.name = name
        self.image = image
        self.message = message
        self.isSelf = isSelf
    }
}

class MessageTableViewCell: UITableViewCell {
    
    struct MessageViewUpdate {
        let message: String?
        let author: String?
    }
    
    class MessageView: UIView {
        private let messageLabel: UILabel
        private let authorLabel: UILabel
        private let stackView: UIStackView
        
        override init(frame: CGRect) {
            self.stackView = UIStackView(frame: .zero)
            self.messageLabel = UILabel(frame: .zero)
            self.authorLabel = UILabel(frame: .zero)
            super.init(frame: frame)
            stackView.forceAutoLayout()
            addSubview(stackView)
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            stackView.spacing = 5.0
            stackView.sizeAndCenter(to: self)
            messageLabel.forceAutoLayout()
            authorLabel.forceAutoLayout()
            stackView.addArrangedSubview(messageLabel)
            stackView.addArrangedSubview(authorLabel)
            authorLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
            setNeedsLayout()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update(with update: MessageViewUpdate?) {
            guard let actualUpdate = update else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                if let actualMessage = actualUpdate.message {
                    self?.messageLabel.text = actualMessage
                } else {
                    self?.messageLabel.text = nil
                }
                if let actualAuthor = actualUpdate.author {
                    self?.authorLabel.text = "from: \(actualAuthor)"
                } else {
                    self?.authorLabel.text = nil
                }
                self?.setNeedsLayout()
            }
        }
    }
    
    let stackView: UIStackView
    let messageView: MessageView
    let avatarView: UIImageView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.stackView = UIStackView(frame: .zero)
        self.avatarView = UIImageView(frame: .zero)
        self.messageView = MessageView(frame: .zero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.fakeClear
        stackView.forceAutoLayout()
        contentView.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.sizeAndCenter(to: contentView)
        
        stackView.addArrangedSubview(avatarView)
        avatarView.forceAutoLayout()
        avatarView.roundCorners()
        avatarView.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1.0, constant: -5.0).isActive = true
        
//        stackView.addArrangedSubview(messageView)
        
        setNeedsLayout()
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
        DispatchQueue.main.async { [weak self] in
            guard let actualMessageView = self?.messageView else {
                return
            }
            if update.isSelf {
                self?.stackView.insertArrangedSubview(actualMessageView, at: 0)
                self?.backgroundColor = .cyan
            } else {
                self?.stackView.addArrangedSubview(actualMessageView)
            }
            let messageUpdate = MessageViewUpdate(message: update.message, author: update.name)
            self?.messageView.update(with: messageUpdate)
            self?.avatarView.image = update.image
            self?.setNeedsLayout()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.removeArrangedSubview(messageView)
        messageView.update(with: nil)
        avatarView.image = nil
        backgroundColor = UIColor.fakeClear
    }

}
