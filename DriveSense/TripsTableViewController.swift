//
//  TripsTableViewController.swift
//  DriveSense
//
//  Created by Matt Kostelecky on 5/3/15.
//  Copyright (c) 2015 Matt Kostelecky. All rights reserved.
//

import Foundation
import UIKit

class TripsTableViewController: UITableViewController {
 
  var trips: NSArray!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTable", name: "updateTable", object: nil)
  }
  
  func updateTable() {
    trips = TripRecorder.sharedInstance.getTrips() as NSArray
    tableView.reloadData()
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    println(trips)
    if trips == nil {
      return 1
    }
    return trips.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    var cell: TripsTableViewCell! = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! TripsTableViewCell
    println(trips)
    if trips == nil {
      return cell
    }
    let trip: Trip! = trips.objectAtIndex(indexPath.row) as! Trip
    
    cell.namelabel.text = trip.name
    cell.dateLabel.text = trip.date
    cell.durationLabel.text = "1 hour"
    cell.distanceLabel.text = "10 miles"
    
    return cell
  }
  
}
