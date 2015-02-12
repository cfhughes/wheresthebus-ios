//
//  StopsViewController.swift
//  ABQWTB
//
//  Created by Chris Hughes on 11/20/14.
//  Copyright (c) 2014 Chris Hughes. All rights reserved.
//

import Foundation

class StopsMapViewController : GAITrackedViewController,GMSMapViewDelegate {
    
    var selected:Int?
    let locationmgr = CLLocationManager()
    var mapView:GMSMapView?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.screenName = "StopsMapiOS"
        mapView!.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.allZeros, context: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if (locationmgr.respondsToSelector("requestWhenInUseAuthorization")){
        //    locationmgr.requestWhenInUseAuthorization()
        //}

        var camera = GMSCameraPosition.cameraWithLatitude(35.0827,longitude:-106.6483, zoom:17)
        
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera:camera)
        
        mapView!.settings.myLocationButton = true
        mapView!.settings.rotateGestures = false
        mapView!.settings.tiltGestures = false
        //mapView.mapType = kGMSTypeHybrid;
        mapView!.delegate = self
        
        self.view = mapView
        
        mapView!.myLocationEnabled = true
        
        
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "myLocation"){
            mapView?.removeObserver(self, forKeyPath: "myLocation")
            let location = object.myLocation
            
            let update = GMSCameraUpdate.setTarget(location!.coordinate)
            
            mapView?.moveCamera(update)
        }
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        let visible = mapView.projection.visibleRegion()
        loadStops(visible.nearRight.latitude, lonmin: visible.farLeft.longitude, latmax: visible.farRight.latitude, lonmax: visible.farRight.longitude)
    }
    
    func loadStops(latmin: CLLocationDegrees, lonmin: CLLocationDegrees, latmax: CLLocationDegrees, lonmax: CLLocationDegrees){
        (self.view as GMSMapView).clear()
        stops.removeAllObjects()
        if ((self.view as GMSMapView).camera.zoom > 16){
            let stmt = db.query("SELECT * FROM stops_local WHERE stop_lat > \(latmin) AND stop_lat < \(latmax) AND stop_lon > \(lonmin) AND stop_lon < \(lonmax)")
            
            while (sqlite3_step(stmt) == SQLITE_ROW){
                let lat = sqlite3_column_double(stmt, 0)
                let lon = sqlite3_column_double(stmt, 2)
                
                let position = CLLocationCoordinate2D(latitude: lat,longitude: lon)
                
                //println(position)
                
                let marker: GMSMarker = GMSMarker(position: position)
                
                marker.title = "\(String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(stmt, 4)))!) (\(String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(stmt, 5)))!))"
                let code = sqlite3_column_int(stmt, 1)
                stops.setValue(Int(code), forKey: marker.hash.description)
                
                let stmt_r = db.query("SELECT * FROM route_stop_map WHERE stop_code = \(code)")
                var routes = ""
                while (sqlite3_step(stmt_r) == SQLITE_ROW){
                    routes += "\(String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(stmt_r, 0)))!) "
                }
                marker.snippet = routes
                marker.icon = UIImage(named: "icon")
                
                marker.map = self.view as GMSMapView
                
                if (Int(code) == selected){
                    (self.view as GMSMapView).selectedMarker = marker
                }
                
            }
        }
        
    }
    
    let stops: NSMutableDictionary = NSMutableDictionary()
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        println(stops.valueForKey(marker.hash.description) as Int)
        //let stopView = StopViewController()
        let stop = stops.valueForKey(marker.hash.description) as Int
        //self.navigationController?.pushViewController(stopView, animated: true)
        performSegueWithIdentifier("stopdetail", sender: stop)
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        mapView.selectedMarker = marker
        selected = stops.valueForKey(marker.hash.description) as? Int
        return true
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        selected = nil
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopdetail"){
            let svc:StopViewController = segue.destinationViewController as StopViewController
            svc.stopID = sender as Int
        }
    }
    
    @IBOutlet var info:UIButton!
    
    @IBAction func infoButton(){
        let infoView = InfoViewController()
        
        infoView.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen

        self.navigationController?.presentViewController(infoView, animated: false, completion: nil)
    }
}
