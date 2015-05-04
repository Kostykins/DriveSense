//
//  Trip.swift
//  DriveSense
//
//  Created by Matt Kostelecky on 5/3/15.
//  Copyright (c) 2015 Matt Kostelecky. All rights reserved.
//

import Foundation
import CoreData

class Trip: NSManagedObject {

    @NSManaged var date: String
    @NSManaged var name: String
    @NSManaged var coordinates: NSOrderedSet
    @NSManaged var endCoordinate: GPSCoordinate
    @NSManaged var startCoordinate: GPSCoordinate

}
