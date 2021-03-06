//
//  MapViewController.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/10/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: Properties
    
    let centerAmericaLat: CLLocationDegrees = 39.8283
    let centerAmericaLong: CLLocationDegrees = -98.5795
    
    // sets the latitudinal and longitudinal distances (for setting map region)
    let latitudinalDist: CLLocationDistance = 5000000   // represents 5 million meters, or 5 thousand kilometers
    let longitudinalDist: CLLocationDistance = 5000000  // represents 5 million meters, or 5 thousand kilometers
    
    let dupPinMsg = "You have already posted a student location. Would you like to overwrite this location?"
    
    // MARK: Outlets
    
    @IBOutlet weak var map: MKMapView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        setDefaultRegion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLocations()
    }
    
    func updateLocations() {
        ParseClient.sharedInstance().getLocations { (success, errorTitle, errorDescription) in
            performUIUpdatesOnMain {
                if success || errorTitle == "Warning" {
                    // clears the current annotations from the map
                    let currentAnnotations = self.map.annotations
                    self.map.removeAnnotations(currentAnnotations)
                    // adds the new annotations to the map:
                    self.map.addAnnotations(SharedStudentData.sharedInstance().students)
                }
                if success == false {
                    self.showAlert(title: errorTitle!, message: errorDescription!)
                }
            }
        }
    }
    
    func setDefaultRegion() {
        let regionLocation = CLLocationCoordinate2DMake(centerAmericaLat, centerAmericaLong)
        map.setRegion(MKCoordinateRegionMakeWithDistance(regionLocation, latitudinalDist, longitudinalDist), animated: true)
    }
    
    // MARK: IBActions
    
    @IBAction func logout(_ sender: Any) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            UdacityClient.sharedInstance().deleteSession(completionHandler: { (success, errorString) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(errorString!)
                    self.showAlert(title: "Logout Failed", message: "You were unable to logout.")
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addPin(_ sender: Any) {
        if ParseClient.sharedInstance().userAlreadyPostedAPin() {
            let alert = UIAlertController(title: "Duplicate Pin", message: dupPinMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .`default`, handler: { (action) in
                self.performSegue(withIdentifier: "mapToAddPin", sender: self)
            }))
            present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "mapToAddPin", sender: self)
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        setDefaultRegion()
        updateLocations()
    }
    
    // MARK: Helper Functions
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "student pin") {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "student pin")
            annotationView.canShowCallout = true
            
            // without adding this UIButton, the 'calloutAccessoryControlTapped' method would not get called!!!
            let infoButton = UIButton(type: .detailDisclosure)
            annotationView.rightCalloutAccessoryView = infoButton
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // code review suggestion:
        // You could also check if the user tapped the "Detail" accessory on the right of the annotation by adding the following line of code:
        /*
        if control == view.rightCalloutAccessoryView {
            ...
        }
        */
        if let mapPin = view.annotation as? MapPinAnnotation {
            if let url = URL(string: mapPin.subtitle!), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                showAlert(title: "Invalid URL", message: "This student's media URL is invalid.")
            }
        }
    }
    
}
