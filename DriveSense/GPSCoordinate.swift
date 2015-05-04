//
//  GPSCoordinate.swift
//  DriveSense
//
//  Created by Matt Kostelecky on 5/3/15.
//  Copyright (c) 2015 Matt Kostelecky. All rights reserved.
//

import Foundation
import CoreData

class GPSCoordinate: NSManagedObject {
  
  var lat: NSNumber = NSNumber()
  var lon: NSNumber = NSNumber()
  var timeStamp: NSDate = NSDate()
  
}
