//
//  Row.swift
//  PlaySleepRecordAlarm
//
//  Created by Vlad Zhaglevskiy on 07.05.2020.
//  Copyright © 2020 None. All rights reserved.
//

import UIKit

protocol TableViewCellType {
    static var identifier: String {get}
}

protocol RowDescription {
    var cellIdentifier: String {get}
    var isEnabled: Bool {get}
    
    func handleSelection(at: IndexPath)
    func configure(cell: UITableViewCell, at: IndexPath)
}

struct Row<CellType: UITableViewCell & TableViewCellType>: RowDescription {
    
    // MARK:- Properties
    
    var cellIdentifier: String {
        return CellType.identifier
    }
    
    public typealias RowConfigurator = (_ cell: CellType, _ indexPath: IndexPath) -> Void
    public typealias RowSelector = (_ indexPath: IndexPath) -> Void
    
    private let configureHandler: RowConfigurator?
    private let selectionHandler: RowSelector?
    
    let isEnabled: Bool
    
    // MARK:- Initialization
    
    init(configure: RowConfigurator? = nil, selection: RowSelector? = nil, isEnabled: Bool = false) {
        configureHandler = configure
        selectionHandler = selection
        
        self.isEnabled = isEnabled
    }
    
    // MARK:- Handle Selection

    func handleSelection(at indexPath: IndexPath) {
        selectionHandler?(indexPath)
    }
    
    // MARK:- Configuration
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let castedCell = cell as? CellType else {
            return
        }
        
        configureHandler?(castedCell, indexPath)
    }
}
