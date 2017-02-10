//
//  ClientConsoleView.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub
import CoreData

extension UIColor {
    static var fakeClear: UIColor {
        // [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]
//        return UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 0.5)
        return UIColor.clear
    }
}

@objc
protocol ClientConsoleViewDelegate: NSObjectProtocol {
    // func scrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func consoleViewDidMove(_ consoleView: ClientConsoleView)
    // public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    @objc optional func consoleViewCurrentUserIdentifier(_ consoleView: ClientConsoleView) -> String?
}

class ClientConsoleView: UIView, UITableViewDataSource, NSFetchedResultsControllerDelegate, UITableViewDelegate, UIScrollViewDelegate {
    
    let tableView: UITableView
    let fetchRequest: NSFetchRequest<Event>
    let fetchedResultsController: NSFetchedResultsController<Event>
    
    weak var delegate: ClientConsoleViewDelegate?
    
    required init(fetchRequest: NSFetchRequest<Event>) {
        self.tableView = UITableView(frame: .zero, style: .plain)
        self.fetchRequest = fetchRequest
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        super.init(frame: .zero)
        backgroundColor = UIColor.fakeClear
        tableView.backgroundColor = UIColor.fakeClear
        fetchedResultsController.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100.0
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.forceAutoLayout()
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.reuseIdentifier())
        addSubview(tableView)
        let widthConstraint = NSLayoutConstraint(item: tableView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0)
        let centerXConstraint = NSLayoutConstraint(item: tableView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: tableView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error.localizedDescription)")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITableViewDataSource
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        DataController.sharedController.viewContext.perform {
            guard let eventCell = cell as? MessageTableViewCell else {
                fatalError()
            }
            guard let message = self.fetchedResultsController.object(at: indexPath) as? Message else {
                return
            }
            
            var update = MessageCellUpdate(name: message.publisherName!, image: message.thumbnail, message: message.message)
            if let publisherID = message.publisher, let messageID = self.delegate?.consoleViewCurrentUserIdentifier?(self), publisherID == messageID {
                update.isSelf = true
            }
            // Populate cell from the NSManagedObject instance
            eventCell.update(with: update)
        }
    }
    
    func scrollToBottom(animated: Bool = false) {
        guard let sectionCount = fetchedResultsController.sections?.count, let lastSection = fetchedResultsController.sections?[sectionCount - 1] else {
            return
        }
        let lastRow = lastSection.numberOfObjects
        guard lastRow != 0 else {
            return
        }
        let lastIndexPath = IndexPath(row: lastRow - 1, section: sectionCount - 1)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.reuseIdentifier(), for: indexPath)
        configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    // MARK: - UIScrollViewDelegate

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.consoleViewDidMove?(self)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let insertedIndexPath = newIndexPath!
            tableView.insertRows(at: [insertedIndexPath], with: .automatic)
            if insertedIndexPath.row == (controller.sections![insertedIndexPath.section].numberOfObjects - 1) {
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: insertedIndexPath, at: .bottom, animated: true)
                }
            }
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            guard let cell = tableView.cellForRow(at: indexPath!) else {
                fatalError()
            }
            configureCell(cell: cell, indexPath: indexPath!)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
