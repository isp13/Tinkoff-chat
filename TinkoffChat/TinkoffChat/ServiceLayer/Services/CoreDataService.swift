//
//  CoreDataService.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 11.04.2021.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    var mainContext: NSManagedObjectContext { get }
}

class CoreDataService: CoreDataServiceProtocol {
    
    var coreDataStack: CoreDataStackProtocol
    
    lazy var mainContext: NSManagedObjectContext = {
        return coreDataStack.mainContext
    }()
    
    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
        self.coreDataStack.addStatisticObserver()
    }
    
}
