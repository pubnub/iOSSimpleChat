//
//  ConfigurationViewController.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

class ConfigurationViewController: UIViewController, ConfigurationViewDelegate {
    
    private var configurationViewContext = 0
    
    private var updateButton: UIBarButtonItem?
    
    var instructionsLabel: UILabel?
    
    var configurationView: ConfigurationView?
    
    var configuration: PNConfiguration! {
        didSet {
            configurationView?.configuration = configuration
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds = UIScreen.main.bounds
        var topPadding = UIApplication.shared.statusBarFrame.height
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            topPadding += navBarHeight
        }
        let instructionsLabelFrame = CGRect(x: bounds.origin.x, y: bounds.origin.y + topPadding, width: bounds.size.width, height: (bounds.size.height * (1.0/5.0)))
        let configViewFrame = CGRect(x: bounds.origin.x, y: instructionsLabelFrame.origin.y + instructionsLabelFrame.size.height, width: bounds.size.width, height: bounds.size.height - topPadding - instructionsLabelFrame.size.height)
        instructionsLabel?.frame = instructionsLabelFrame
        configurationView?.frame = configViewFrame
        view.frame = bounds
    }
    
    override func loadView() {
        configurationView = ConfigurationView(frame: .zero, config: configuration)
        instructionsLabel = UILabel(frame: .zero)
        let backgroundView = UIView(frame: .zero)
        backgroundView.addSubview(instructionsLabel!)
        backgroundView.addSubview(configurationView!)
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
        configurationView?.delegate = self
        instructionsLabel?.textAlignment = .center
        instructionsLabel?.numberOfLines = 0
        instructionsLabel?.adjustsFontSizeToFitWidth = true
        instructionsLabel?.backgroundColor = .cyan
        view.backgroundColor = .red
        navigationItem.title = "Client Configuration"
        updateButton = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateButtonPressed(sender:)))
        navigationItem.rightBarButtonItem = updateButton
        configurationView?.reloadData()
        view.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configurationView?.addObserver(self, forKeyPath: #keyPath(ConfigurationView.hasChanges), options: [.old, .new, .initial], context: &configurationViewContext)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        configurationView?.removeObserver(self, forKeyPath: #keyPath(ConfigurationView.hasChanges), context: &configurationViewContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func updateButtonPressed(sender: UIBarButtonItem) {
//        Network.sharedNetwork.client.copyWithConfiguration(configuration, completion: { (updatedClient) in
//            Network.sharedNetwork.client = updatedClient
//            self.configurationView?.resetChanges()
//        })
        Network.sharedNetwork.updateClient(with: configuration) { (_) in
            self.configurationView?.resetChanges()
        }
    }
    
    func updateUpdateButton() {
        guard let existingConfigurationView = configurationView else {
            DispatchQueue.main.async {
                self.updateButton?.isEnabled = false
            }
            return
        }
        DispatchQueue.main.async {
            self.updateButton?.isEnabled = existingConfigurationView.hasChanges
        }
    }
    
    func updateInstructionsLabel() {
        DispatchQueue.main.async {
            self.instructionsLabel?.text = "Tap any property to change it. Make sure to select \"Update\" (in upper right) to persist any changes"
            self.view.setNeedsLayout()
        }
    }
    
    // MARK: - KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &configurationViewContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(ConfigurationView.hasChanges):
                updateUpdateButton()
                updateInstructionsLabel()
            default:
                fatalError("what wrong in KVO?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - ConfigurationViewDelegate
    
    func configurationView(_ configurationView: ConfigurationView, for configuration: PNConfiguration, didSelect keyValue: KeyValue, at indexPath: IndexPath) {
        guard var alertKeyValue = keyValue as? KeyValueAlertControllerUpdates else {
            return
        }
        let alertController = alertKeyValue.updateAlertController { (action, keyValue) in
            self.configurationView?.reloadItems(at: [indexPath])
        }
        present(alertController, animated: true)
    }

}
