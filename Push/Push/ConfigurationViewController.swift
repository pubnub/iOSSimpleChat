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
