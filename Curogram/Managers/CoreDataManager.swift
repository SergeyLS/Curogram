//
//  CoreDataManager.swift
//  TheMovieDB
//
//  Created by Sergey Leskov on 1/29/17.
//  Copyright © 2017 Sergey Leskov. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class CoreDataManager {
    
    //==================================================
    // MARK: - Singleton
    //==================================================
    static let shared = CoreDataManager()
    private init() {
    }
    
    //==================================================
    // MARK: - Properties
    //==================================================
    private lazy var storeUrl: URL = {
        var resultUrl: URL?
        let applicationDocumentsDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        resultUrl = applicationDocumentsDirectoryURL.appendingPathComponent("CoreDataStorage.sqlite")
        
        return resultUrl!
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var resultCoordinator: NSPersistentStoreCoordinator?
        
        resultCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            let options = [ NSInferMappingModelAutomaticallyOption : true,
                            NSMigratePersistentStoresAutomaticallyOption : true]
            
            try resultCoordinator?.addPersistentStore(ofType:NSSQLiteStoreType, configurationName: nil, at: self.storeUrl, options: options)
        } catch let errror {
            print("Couldn't addPersistentStore")
            
            resultCoordinator = nil
            do {
                try FileManager.default.removeItem(at: self.storeUrl)
            } catch let errror {
                print("Couldn't removeItem: \(self.storeUrl)")
                
                return resultCoordinator
            }
            
            print("Wipe DB: \(self.storeUrl)")
        }
        
        return resultCoordinator
    }()
    
    private lazy var rootContext: NSManagedObjectContext = {
        let resultContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        resultContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        resultContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return resultContext
    }()
    
    public lazy var viewContext: NSManagedObjectContext = {
        let resultContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        resultContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        resultContext.parent = self.rootContext
        
        return resultContext
    }()
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        //assert(!Thread.isMainThread, "The method must not be run in the main thread")
        
        let resultContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        resultContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        resultContext.parent = self.viewContext
        
        //resultContext.parent = self.rootContext
        //resultContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return resultContext
    }
    
    //==================================================
    // MARK: - saveContext
    //==================================================
    public func save(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
    //public func save(context: NSManagedObjectContext ) {
        var lasError: Error?
        var currContext: NSManagedObjectContext? = context
        
        repeat {
            if let aContext = currContext {
                //                print("[CoreDataM] save: BEGIN \(String(describing: aContext))")
                aContext.performAndWait { [unowned uoContext = aContext] in
                    do {
                        try uoContext.save()
                        //                        print("[CoreDataM] save: END \(uoContext)")
                    } catch let error {
                        print("Couldn't save context! Error: \(error)")
                        lasError = error
                    }
                }
            }
            currContext = currContext?.parent
        } while  currContext != nil && lasError == nil
    }
}


