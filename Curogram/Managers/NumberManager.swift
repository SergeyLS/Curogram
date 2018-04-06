//
//  NumberManager.swift
//  Curogram
//
//  Created by Sergey Leskov on 4/6/18.
//  Copyright © 2018 Sergey Leskov. All rights reserved.
//

import Foundation
import CoreData

class NumberManager {
    static func getByUid(uid: String, moc: NSManagedObjectContext) -> Number? {
        
        if uid.isEmpty { return nil }
        
         let request = NSFetchRequest<Number>(entityName: Number.entityName())
        
        var arrayPredicate:[NSPredicate] = []
        arrayPredicate.append(NSPredicate(format: "uid = %@", uid))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: arrayPredicate)
        request.predicate = predicate
        
        let resultsArray = try? moc.fetch(request)
        
        return resultsArray?.first ?? nil
    }

}
