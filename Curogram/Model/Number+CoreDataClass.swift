//
//  Number+CoreDataClass.swift
//  Curogram
//
//  Created by Sergey Leskov on 4/6/18.
//  Copyright © 2018 Sergey Leskov. All rights reserved.
//
//

import Foundation
import CoreData


public class Number: NSManagedObject {

    class func entityName() -> String {
        return "Number"
    }

    convenience init? (id: Int64, moc: NSManagedObjectContext) {
        guard let tempEntity = NSEntityDescription.entity(forEntityName: Number.entityName(), in: moc) else {
            fatalError("Could not initialize!")
            return nil
        }
        self.init(entity: tempEntity, insertInto: moc)

        self.id = id
        self.uid = UUID().uuidString
        
        print("- add new id: \(id)")
    }

}
