
//
//  MapRootViewController.swift
//  DriveSense
//
//  Created by Matt Kostelecky on 5/3/15.
//  Copyright (c) 2015 Matt Kostelecky. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapRootViewController: UIViewController, MKMapViewDelegate{
  
  
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var mapView: MKMapView!
  
  //container and recording bar
  @IBOutlet weak var container: UIView!
  @IBOutlet var bottomBar: UIView!

  //labels for slide in view
  @IBOutlet weak var tripLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
 
  //flag to indicate controller that is currently recording
  var recording: Bool!
  var showingTrips: Bool!
  
  var locationManager: CLLocationManager!
  var tripRecorder: TripRecorder!
  
  //used to save the final position of the view on the screen so we can animate to here later
  var frameIn: CGRect!
  var frameContainer: CGRect!
  
  //Timer variables
  var secondsCounting: NSInteger!
  var durationTimer: NSTimer!
  var trips: NSArray!
  
  override func viewDidLoad() {
    self.recording = false
    self.showingTrips = false
    self.tripRecorder = TripRecorder.sharedInstance
    self.locationManager = self.tripRecorder.getLocationManager()
    mapView.delegate = self
    self.trips = self.tripRecorder.getTrips() as NSArray
    secondsCounting = 0;
    
  }
  
  override func viewDidAppear(animated: Bool) {
    
    tripLabel.text = "Name PlaceHolder"
    durationLabel.text = NSString(format: "%d seconds", secondsCounting) as String
    
    mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
    
    frameIn = self.bottomBar.frame
    if(self.container != nil){
      frameContainer = self.container.frame
    }
    
    animateOut()
    if(self.container != nil){
      animateTableOut()
    }
    
  }
  
  // MARK: - Button Methods

  
  @IBAction func settings(sender: UIButton) {
    
    let params = NSMutableDictionary(objectsAndKeys:
                "CS407 DriveSense Share", "name",
                "Sample Post.", "caption",
                "I just  learned how to set up Facebook Integration with iOS apps. If you want to do the same, you should take CS407 next semester!", "description",
                "http://pages.cs.wisc.edu/~suman/courses/wiki/doku.php?id=407-spring2014", "link",
                "http://i.imgur.com/g3Qc1HN.png", "picture")
    
    FBWebDialogs.presentFeedDialogModallyWithSession(nil,
      parameters: params as [NSObject : AnyObject],
      handler:{ (result: FBWebDialogResult, resultURL: NSURL!, error: NSError!) in
        if ((error) != nil) {
          // An error occurred, we need to handle the error
          // See: https://developers.facebook.com/docs/ios/errors
          println(NSString(format: "Error publishing story: %@", error.description))
        } else {
          if (resultURL == nil) {
            // User cancelled.
            println("User cancelled.")
          } else {
            // Handle the publish feed callback
            let urlParams = self.parseURLParams(resultURL.query!)
            
            if (urlParams.valueForKey("post_id") != nil) {
              // User cancelled.
              println("User cancelled.")
              
            } else {
              // User clicked the Share button
              let result = NSString(format: "Posted story, id: %@", urlParams.valueForKey("post_id") as! String)
              println("result %@", result);
            }
          }
        }
    })
    
  }
  
  @IBAction func togglePlayButton(sender: AnyObject) {
    if (recording == true) {
      if(playButton != nil){
        playButton.setBackgroundImage(UIImage(named: "play"), forState: UIControlState.Normal)
      }
      
      //reset the timer
      self.durationTimer.invalidate()
      //dont follow user around when not tracking
      mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: true)
      
      var bool = self.tripRecorder.stopRecording()
      animateOut()
      
    } else {
      if(playButton != nil){
        playButton.setBackgroundImage(UIImage(named: "pause"), forState: UIControlState.Normal)
      }
      
      // follow user around when tracking
      mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true)
      
      //set timer
      self.durationTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "incrementTimer", userInfo: nil, repeats: true)
      secondsCounting = 0
      
      var bool = self.tripRecorder.startRecording()
      animateIn()
    }
    recording = !recording
  }
  
  @IBAction func showTrips(sender: AnyObject) {
    if(recording == true){
      return
    }
    if (showingTrips == true) {
      mapView.removeAnnotations(mapView.annotations)
      mapView.removeOverlays(mapView.overlays)
      if(self.container != nil){
        animateTableOut()
      }
    } else {
      NSNotificationCenter.defaultCenter().postNotificationName("updateTable", object: nil)
      var trips: NSArray = self.tripRecorder.getTrips() as NSArray
      println(trips.count)
      for(var i = 0; i < trips.count; i++) {
        let trip: Trip = trips.objectAtIndex(i) as! Trip
        let coordinates: NSOrderedSet = trip.coordinates
        drawRouteForCoordinates(coordinates)
        dropPinForCoordinate(trip.startCoordinate)
        dropPinForCoordinate(trip.endCoordinate)
      }
      if(self.container != nil){
        animateTableIn()
      }
    }
     showingTrips = !showingTrips;
  }
  
  
  func parseURLParams(query: NSString) -> NSDictionary{
    let pairs = query.componentsSeparatedByString("&") as NSArray
    var params: NSMutableDictionary = NSMutableDictionary()
    for (var i = 0; i < pairs.count; i++) {
      var kv = pairs.objectAtIndex(i).componentsSeparatedByString("=") as NSArray
      let val = kv.objectAtIndex(1).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
      params.setValue(val, forKey: kv.objectAtIndex(0) as! String)
      
    }
    return params
  }
  
  
  // MARK: - Trip Timing
  func incrementTimer(){
    secondsCounting = secondsCounting + 1
    durationLabel.text = NSString(format: "%d seconds", secondsCounting) as String
  }
  
  // MARK: - Animation Methods
  func animateTableIn(){
    UIView.animateWithDuration(0.25, animations: {
      self.container.frame = self.frameContainer
      self.container.alpha = 1
    })
  }
  
  func animateTableOut(){
    UIView.animateWithDuration(0.25, animations: {
      let y = self.view.frame.size.height
      var newFrame = self.frameContainer
      newFrame.origin.y = y
      self.container.frame = newFrame
      self.container.alpha = 0
    })
  }
  
  func animateIn(){
    UIView.animateWithDuration(0.25, animations: {
      self.bottomBar.frame = self.frameIn
    })
    if(self.container != nil){
      self.container.alpha = 0
    }
  }
  
  func animateOut(){
    UIView.animateWithDuration(0.25, animations: {
      let y = self.view.frame.size.height
      var newFrame = self.frameIn
      newFrame.origin.y = y
      self.bottomBar.frame = newFrame
    })
    if(self.container != nil){
      self.container.alpha = 1
    }
  }
  
 // MARK: - Map Drawing
  func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
    //check to make sure it is a polyline (this method is called for anything else thats drawn on a map)
    if !overlay.isKindOfClass(MKPolygon) {
      let route: MKPolyline = overlay as! MKPolyline
      let renderer: MKPolylineRenderer = MKPolylineRenderer(polyline: route)
      renderer.strokeColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
      renderer.lineWidth = 3.0
      return renderer
    } else {
      return nil
    }
  }
  
  func drawRouteForCoordinates(points: NSOrderedSet) {
    //draw the route for the map based on the coordiantes
    var pointArray: [CLLocationCoordinate2D] = []
    
    for(var i = 0; i < points.count; i++){
      let coordinate: GPSCoordinate = points.objectAtIndex(i) as! GPSCoordinate
      
      let lat = coordinate.lat.doubleValue
      let lon = coordinate.lon.doubleValue
      
      pointArray.append(CLLocationCoordinate2DMake(lat, lon))
    }
    let count = points.count
    let myPolyline = MKPolyline(coordinates: &pointArray, count: count)
    mapView.addOverlay(myPolyline)
  }
  
  func dropPinForCoordinate(coordinate: GPSCoordinate) {

    let lat = coordinate.lat.doubleValue
    let lon = coordinate.lon.doubleValue
    
    let coordinate2D: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
    
    var annotation: MapAnnotation = MapAnnotation(coordinate: coordinate2D, title: "Title", subtitle: "Subtitle")
  
    mapView.addAnnotation(annotation)
  }
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    if (annotation is MKUserLocation) {
      //if annotation is not an MKPointAnnotation (eg. MKUserLocation),
      //return nil so map draws default view for it (eg. blue dot)...
      return nil
    }
    
    let reuseId = "MapAnnotation"
    
    var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
    if anView == nil {
      anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      anView.canShowCallout = true
    }
    else {
      //we are re-using a view, update its annotation reference...
      anView.annotation = annotation
    }

    return anView
  }
  
  func printTrips() {
    let trips: NSArray = self.tripRecorder.getTrips()
    println(NSString(format: "SharedModel: loaded %lu trips from database", trips.count))
    
    for(var i = 0; i < trips.count; i++) {
      let trip: Trip = trips.objectAtIndex(i) as! Trip
      println(NSString(format: "%@ has %lu coordinates, date: %@", trip.name, trip.coordinates.count, trip.date))
    }
  }
}
