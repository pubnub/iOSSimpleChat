//
//  ConfigurationView.swift
//  Push
//
//  Created by Jordan Zucker on 1/24/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub

protocol ConfigurationViewDelegate: class {
//    optional public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func configurationView(_ configurationView: ConfigurationView, for configuration: PNConfiguration, didSelect keyValue: KeyValue, at indexPath: IndexPath)
}

class ConfigurationView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    struct DataSource {
        private var items = [ConfigurationProperty]()
        
        mutating func update(configuration: PNConfiguration) {
            self.items = [.publishKey(configuration), .subscribeKey(configuration), .origin(configuration), .authKey(configuration), .uuid(configuration)]
        }
        
        init(configuration: PNConfiguration) {
            update(configuration: configuration)
        }
        
        var count: Int {
            return items.count
        }
        
        var sections: Int {
            return 1 // hard-coded
        }
        
        subscript(item: Int) -> ConfigurationProperty {
            get {
                return items[item]
            }
        }
        
        subscript(indexPath: IndexPath) -> ConfigurationProperty {
            get {
                return self[indexPath.item]
            }
        }
        
    }
    
    weak var delegate: ConfigurationViewDelegate?
    var dataSource: DataSource!
    
    override var frame: CGRect {
        didSet {
            collectionView.frame = bounds
            setNeedsLayout()
        }
    }
    
    private let collectionView: UICollectionView!
    
    required init(frame: CGRect, config: PNConfiguration) {
        self.configuration = config
        let layout = UICollectionViewFlowLayout()
//        layout.estimatedItemSize = CGSize(width: 100.0, height: 100.0)
        layout.itemSize = CGSize(width: 150.0, height: 100.0)
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.backgroundColor = .white
        dataSource = DataSource(configuration: configuration)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(KeyValueLabelCollectionViewCell.self, forCellWithReuseIdentifier: KeyValueLabelCollectionViewCell.reuseIdentifier())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
    
    var configuration: PNConfiguration {
        didSet {
            dataSource.update(configuration: configuration)
            collectionView.reloadData()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let keyValueLabelsCell = collectionView.dequeueReusableCell(withReuseIdentifier: KeyValueLabelCollectionViewCell.reuseIdentifier(), for: indexPath) as? KeyValueLabelCollectionViewCell else {
            fatalError("Wrong cell type")
        }
        let keyValueItem = dataSource[indexPath]
        keyValueLabelsCell.update(with: keyValueItem)
        return keyValueLabelsCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keyValueItem = dataSource[indexPath]
        print(keyValueItem.debugDescription)
        
        delegate?.configurationView(self, for: configuration, didSelect: keyValueItem, at: indexPath)
        
    }

}
