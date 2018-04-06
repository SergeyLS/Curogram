//
//  Number+CoreDataProperties.swift
//  Curogram
//
//  Created by Sergey Leskov on 4/6/18.
//  Copyright © 2018 Sergey Leskov. All rights reserved.
//
//

import Foundation
import CoreData


extension Number {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Number> {
        return NSFetchRequest<Number>(entityName: "Number")
    }

    @NSManaged public var id: Int64
    @NSManaged public var uid: String?

}
