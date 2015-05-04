//
//  IPadViewController.swift
//  DriveSense
//
//  Created by Matt Kostelecky on 5/4/15.
//  Copyright (c) 2015 Matt Kostelecky. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class IPadViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var viewContainer: UIView!
  @IBOutlet weak var leftContainer: UIView!

  
  var mapVC: MapRootViewController!
  var nav: UINavigationController!
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    var storyBoard = UIStoryboard(name: "Main", bundle: nil)
    var table = storyBoard.instantiateViewControllerWithIdentifier("table") as! TripsTableViewController
    
    self.addChildViewController(table)
    table.didMoveToParentViewController(self)
    leftContainer.addSubview(table.view)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if(segue.identifier == "embed"){
      self.mapVC = segue.destinationViewController as! MapRootViewController
      
    } else if (segue.identifier == "nav"){
      self.nav = segue.destinationViewController as! UINavigationController
    }
  }
  @IBAction func record(sender: AnyObject) {
    mapVC.togglePlayButton(sender)
  }
  @IBAction func trips(sender: AnyObject) {
    mapVC.showTrips(sender)
  }
  @IBAction func settings(sender: AnyObject) {
    mapVC.settings(sender as! UIButton)
  }
  
}