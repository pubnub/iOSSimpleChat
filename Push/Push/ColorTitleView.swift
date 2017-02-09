//
//  ColorTitleView.swift
//  Push
//
//  Created by Jordan Zucker on 2/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit

//struct ColorTitleUpdate {
//    let image: UIImage?
//    let name: String?
//}

class ColorTitleView: UIView {
    
//    let name: String?
//    let image: UIImage?

    let imageView = UIImageView(frame: .zero)
    let titleLabel = UILabel(frame: .zero)
    let stackView = UIStackView(frame: .zero)
    
//    var imageViewWidthConstraint: NSLayoutConstraint!
    
    required init(name: String?, image: UIImage?) {
        super.init(frame: .zero)
        addSubview(stackView)
        //        imageView.forceAutoLayout()
        //        titleLabel.forceAutoLayout()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        stackView.forceAutoLayout()
        stackView.sizeAndCenter(to: self)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)
        titleLabel.forceAutoLayout()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.widthAnchor.constraint(lessThanOrEqualTo: stackView.widthAnchor, multiplier: 0.4).isActive = true
        imageView.forceAutoLayout()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5.0
        imageView.widthAnchor.constraint(lessThanOrEqualTo: stackView.heightAnchor).isActive = true
        imageView.heightAnchor.constraint(lessThanOrEqualTo: imageView.widthAnchor).isActive = true
        
        var titleText = "Color changed by: "
        defer {
            titleLabel.text = titleText
            setNeedsLayout()
        }
        if let actualName = name {
            titleText += "\(actualName)"
        }
        if let actualImage = image {
            imageView.image = actualImage
        } else {
            imageView.image = nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
