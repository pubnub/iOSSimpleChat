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
//        consoleView = ClientConsoleView(fetchRequest: fetchRequest)
//        let bounds = UIScreen.main.bounds
//        consoleView.frame = bounds
//        self.view = consoleView
        let bounds = UIScreen.main.bounds
        stackView = UIStackView(frame: bounds)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
//        stackView.frame = bounds
        self.view = stackView

    }
    
    required init() {
//        self.client = client
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
        pushChannelsButton.setTitle(pushChannelsButtonPlaceholder, for: .normal)
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
        
    }

}
