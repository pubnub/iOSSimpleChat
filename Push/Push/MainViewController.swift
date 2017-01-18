//
//  MainViewController.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub
import CoreData

class MainViewController: UIViewController {
    
    private var mainViewContext = 0
    
//    let client: PubNub
    
    var stackView: UIStackView!
    var pushChannelsButton: UIButton!
    let pushChannelsButtonPlaceholder = "Tap here to add push channels"
    
    let fetchRequest: NSFetchRequest<Result> = {
        let request: NSFetchRequest<Result> = Result.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Result.creationDate), ascending: false)
        request.sortDescriptors = [creationDateSortDescriptor]
        return request
    }()
    
    var consoleView: ClientConsoleView!
    
    override func loadView() {
        let bounds = UIScreen.main.bounds
        stackView = UIStackView(frame: bounds)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        self.view = stackView

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
        navigationItem.title = "Push!"
        pushChannelsButton = UIButton(type: .custom)
        guard let pushBackgroundImage = UIImage(color: .cyan) else {
            fatalError("Couldn't create one color UIImage!")
        }
        pushChannelsButton.setBackgroundImage(pushBackgroundImage, for: .normal)
        pushChannelsButton.addTarget(self, action: #selector(pushChannelsButtonPressed(sender:)), for: .touchUpInside)
        stackView.addArrangedSubview(pushChannelsButton)
        consoleView = ClientConsoleView(fetchRequest: fetchRequest)
        stackView.addArrangedSubview(consoleView)
        
        let pushChannelsButtonVerticalConstraints = NSLayoutConstraint(item: pushChannelsButton, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.25, constant: 0)
        
        NSLayoutConstraint.activate([pushChannelsButtonVerticalConstraints])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func pushChannelsButtonPressed(sender: UIButton) {
        let viewContext = DataController.sharedController.persistentContainer.viewContext
        let pushChannelsAlertController = DataController.sharedController.currentUser().alertControllerForPushChannels(in: viewContext)
        present(pushChannelsAlertController, animated: true)
    }
    
    // MARK: - KVO
    
    // Properties
    
    func pushChannelsButtonTitle() -> String {
        var finalTitle: String? = nil
        DataController.sharedController.persistentContainer.viewContext.performAndWait {
            finalTitle = (DataController.sharedController.currentUser().pushChannelsString ?? self.pushChannelsButtonPlaceholder)
        }
        return finalTitle!
    }
    
    func updatePushChannelsButton() {
        let title = pushChannelsButtonTitle()
        DispatchQueue.main.async {
            self.pushChannelsButton.setTitle(title, for: .normal)
            self.pushChannelsButton.setNeedsLayout()
        }
    }
    
    var currentUser: User? {
        didSet {
            if let existingOldValue = oldValue {
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushChannels), context: &mainViewContext)
            }
            currentUser?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &mainViewContext)
        }
    }
    
    // Deinit
    
    deinit {
        self.currentUser = nil
    }
    
    
    // KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &mainViewContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(User.pushChannels):
                updatePushChannelsButton()
            default:
                fatalError("what wrong in KVO?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    

}
