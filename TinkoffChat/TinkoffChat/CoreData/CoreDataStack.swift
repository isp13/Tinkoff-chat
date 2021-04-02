//
//  CoreDataStack.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 31.03.2021.
//

import Foundation
import CoreData

class CoreDataStack {
    var didUpdateDataBase: ((CoreDataStack) -> Void)?
    
    private lazy var storeURL: URL = {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            fatalError("Documents path not found")
        }
        
        return documentsUrl.appendingPathComponent("Chat.sqlite")
    }()
    
    private let dataModelName = "Chat"
    private let dataModelExtension = "momd"
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource: self.dataModelName, withExtension: self.dataModelExtension) else {
            fatalError("model not found")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("managedObjectModel could not be created")
        }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                               configurationName: nil,
                                               at: self.storeURL,
                                               options: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return coordinator
    }()
    
    // MARK: - Contexts
    
    // контекст для записи в store через Coordinator
    private lazy var writterContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }()
    
    // главный контекст
    private(set) lazy var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = writterContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    // контекст для чтения и записи
    private func saveContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = mainContext
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSOverwriteMergePolicy
        return context
    }
    
    // MARK: - Saving
    
    func performSave(_ block: (NSManagedObjectContext) -> Void) {
        let context = saveContext()
        context.performAndWait {
            block(context)
            if context.hasChanges {
                performSave(in: context)
            }
        }
    }
    
    private func performSave(in context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        
        if let parent = context.parent { performSave(in: parent) }
    }
    
    // MARK: - CoreData Observers
    
    func addStatisticObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(managedObjectContextObjectsDidChange(_:)),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: mainContext)
    }
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        didUpdateDataBase?(self)
        
        let insertCount = (userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>)?.count ?? 0
        Logger.log("добавлено объектов: \(insertCount)")
        
        let updateCount = (userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>)?.count ?? 0
        Logger.log("изменено объектов: \(updateCount)")
        
        let deleteCount = (userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>)?.count ?? 0
        Logger.log("удалено объектов: \(deleteCount)")
        
        // Logger.log(storeURL)
    }
}

// class ModernCoreDataStack {
//    private let dataBaseName = "Chat"
//
//    lazy var container: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: dataBaseName)
//
//        container.loadPersistentStores { storeDescription, error in
//            if let error = error as NSError? {
//                fatalError("something went wrong \(error.localizedDescription)")
//            }
//        }
//        return container
//    }()
// }
