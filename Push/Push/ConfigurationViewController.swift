//
//  ConfigurationViewController.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

class ConfigurationViewController: UIViewController {
    
    var configurationView: ConfigurationView!
    var configuration: PNConfiguration! {
        didSet {
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = UIScreen.main.bounds
        var topPadding = UIApplication.shared.statusBarFrame.height
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            topPadding += navBarHeight
        }
        let configViewFrame = CGRect(x: bounds.origin.x, y: bounds.origin.y + topPadding, width: bounds.size.width, height: bounds.size.height - topPadding)
        configurationView.frame = configViewFrame
        view.frame = bounds
    }
    
    override func loadView() {
//        stackView = UIStackView(frame: .zero)
//        stackView.axis = .vertical
//        stackView.alignment = .fill
//        stackView.distribution = .fill
        configurationView = ConfigurationView(frame: .zero, config: PNConfiguration(publishKey: "demo", subscribeKey: "demo"))
        let backgroundView = UIView(frame: .zero)
        backgroundView.addSubview(configurationView)
        self.view = backgroundView
        self.view.setNeedsLayout()
    }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        navigationItem.title = "Client Configuration"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateButtonPressed(sender:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func updateButtonPressed(sender: UIBarButtonItem) {
        
    }

}
