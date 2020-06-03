//
//  Shift+CoreDataProperties.swift
//  ClockIn
//
//  Created by Luke Jansen on 04/04/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//
//

import Foundation
import CoreData


extension Shift {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Shift> {
        return NSFetchRequest<Shift>(entityName: "Shift")
    }

    @NSManaged public var finish: String
    @NSManaged public var finishDate: Date
    @NSManaged public var id: String
    @NSManaged public var location: String
    @NSManaged public var role: String
    @NSManaged public var start: String
    @NSManaged public var startDate: Date
    @NSManaged public var week: Date
    @NSManaged public var clockIn: Date?
    @NSManaged public var clockOut: Date?
}
