//
//  ViewController.swift
//  MapTemplate2
//
//  Created by derrick on 9/22/14.
//  Copyright (c) 2014 derrick. All rights reserved.
//  Add on info.plist & framework
//  Xcode6-Beta5

import UIKit
import MapKit
class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var locManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.locManager = CLLocationManager()
        addressText.delegate = self
        
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest

        if (locManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
            locManager.requestAlwaysAuthorization()
            locManager.requestWhenInUseAuthorization()
        }
        locManager.startUpdatingLocation()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        println("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addressText.resignFirstResponder()
        return true
    }
    
    @IBAction func barIndex(sender: AnyObject) {
        switch sender.selectedSegmentIndex as Int {
        case 0:
            println("0")
            mapView.mapType = MKMapType.Standard
        case 1:
            println("1")
            mapView.mapType = MKMapType.Satellite
        case 2:
            println("2")
            mapView.mapType = MKMapType.Hybrid
        default:
            println("default")
        }
    }
    
    @IBAction func currentLocation(sender: AnyObject) {
        println("current location")
         mapView.showsUserLocation = true
    }
    
    @IBAction func openMapApp(sender: AnyObject) {
        println("get geocode")
        var geocoder:CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.addressText.text, {(placemarks: [AnyObject]!, error: NSError!) -> Void in
            if let placemark = placemarks?[0] as? CLPlacemark {
                
                //self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
                //var pinitem:MKMapItem = MKMapItem(placemark: placemark as MKPlacemark) // add pinpoint
                var mkPlaceMark: MKPlacemark = MKPlacemark(coordinate: placemark.location.coordinate,
                    addressDictionary: placemark.addressDictionary)
                var mapItem:MKMapItem = MKMapItem(placemark: mkPlaceMark)
                var option = NSDictionary(object: MKLaunchOptionsDirectionsModeDriving, forKey: MKLaunchOptionsDirectionsModeKey)
                mapItem.openInMapsWithLaunchOptions(option)
            }
        })
    }
}

