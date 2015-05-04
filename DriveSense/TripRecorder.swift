//
//  TripRecorder.swift
//  DriveSense
//
//  Created by Matt Kostelecky on 5/3/15.
//  Copyright (c) 2015 Matt Kostelecky. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

private let _TripRecorderSharedInstance = TripRecorder()
class TripRecorder: NSObject, CLLocationManagerDelegate {

  static let sharedInstance = _TripRecorderSharedInstance
  private var locationManager: CLLocationManager!
  var lastReceivedLocation: CLLocation!
  var managedObjectContext: NSManagedObjectContext!
  var trip: Trip!
  var recording: Bool!
  
  override init() {
    super.init()
    recording = false
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 1
    locationManager.requestWhenInUseAuthorization()
    managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
  }
 
  //allows other classes to use singleton location manager
  func getLocationManager() -> CLLocationManager {
    return locationManager
  }
  
  func startRecording() -> Bool{
    locationManager.startUpdatingLocation()
    var ent: AnyObject = NSEntityDescription.insertNewObjectForEntityForName("Trip", inManagedObjectContext: managedObjectContext)
    trip =  ent as! Trip
    let date = NSDate()
    trip.date = NSString(format: "%@", date) as String
    trip.name = "name"
    saveChanges();
    return true
  }
  
  func stopRecording() -> Bool {
    //stop collecting data. Ensure that this is a valid time to do this
    locationManager.stopUpdatingLocation()
    
    var coord: GPSCoordinate = NSEntityDescription.insertNewObjectForEntityForName("GPSCoordinate", inManagedObjectContext: managedObjectContext) as! GPSCoordinate
    coord.lat = NSNumber(double: lastReceivedLocation.coordinate.latitude)
    coord.lon = NSNumber(double: lastReceivedLocation.coordinate.longitude)
    
    trip.endCoordinate = coord
    
    saveChanges()
    //trip = nil
    return true
  }
  
  // MARK: -Core Location Methods
  func getTrips() -> NSArray {
    println("Shared Model: fetching trips... ")
    
    //initializing NSFetchRequest
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: managedObjectContext)
    fetchRequest.entity = entity
    let error = NSErrorPointer()
    // Query on managedObjectContext With Generated fetchRequest, return array
    return managedObjectContext.executeFetchRequest(fetchRequest, error: error)!
  }
  
  func saveChanges(){
    let error = NSErrorPointer()
    if !managedObjectContext.save(error) {
      println(NSString(format: "SharedModel: ERROR saving trip: %@", error.debugDescription))
    }
    
  }
  
  // MARK: - CLLocation Callback
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    lastReceivedLocation = (locations as NSArray).objectAtIndex(0) as! CLLocation
    
    var coord: GPSCoordinate = NSEntityDescription.insertNewObjectForEntityForName("GPSCoordinate", inManagedObjectContext: managedObjectContext) as! GPSCoordinate
    coord.lat = NSNumber(double: lastReceivedLocation.coordinate.latitude)
    coord.lon = NSNumber(double: lastReceivedLocation.coordinate.longitude)
    coord.timeStamp = NSDate()
    
    if trip.startCoordinate.managedObjectContext == nil {
      trip.startCoordinate = coord
    }
    
    var relation = trip.valueForKeyPath("coordinates") as! NSMutableOrderedSet
    relation.addObject(coord)
    
    saveChanges()
  }
}
