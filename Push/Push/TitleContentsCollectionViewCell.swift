//
//  TitleContentsCollectionViewCell.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

protocol Item {
    
}

struct TitleContents: Item {
    let title: String
    let contents: String?
}

protocol ItemCell {
    func update(with item: Item)
}

class TitleContentsCollectionViewCell: UICollectionViewCell, ItemCell {
    
    let titleLabel: UILabel
    let contentsLabel: UILabel
    
    override init(frame: CGRect) {
        self.titleLabel = UILabel(frame: .zero)
        self.contentsLabel = UILabel(frame: .zero)
        super.init(frame: frame)
        titleLabel.forceAutoLayout()
        contentsLabel.forceAutoLayout()
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentsLabel)
//        let widthConstraint = NSLayoutConstraint(item: textView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0.0)
//        let heightConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: 0.0)
//        let centerXConstraint = NSLayoutConstraint(item: textView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
//        let centerYConstraint = NSLayoutConstraint(item: textView, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
//        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
        let views = [
            "titleLabel": titleLabel,
            "contentsLabel": contentsLabel,
        ]
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel][contentsLabel]|", options: [], metrics: nil, views: views)
        let titleWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", options: [], metrics: nil, views: views)
        let contentsWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentsLabel]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(heightConstraints)
        NSLayoutConstraint.activate(titleWidthConstraints)
        NSLayoutConstraint.activate(contentsWidthConstraints)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func update(with item: Item) {
        guard let titleContents = item as? TitleContents else {
            fatalError()
        }
        titleLabel.text = titleContents.title
        contentsLabel.text = titleContents.contents
        contentView.setNeedsLayout()
    }
}
