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
    
    /*
    var selectedPin: MKAnnotation? = nil
    */
    
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
        ParseClient.sharedInstance().getLocations { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.map.addAnnotations(ParseClient.students)
                }
            } else {
                print(errorString!)
                self.showAlert(title: "Unable to Load", message: errorString!)
            }
        }
    }
    
    func setDefaultRegion() {
        let regionLocation = CLLocationCoordinate2DMake(centerAmericaLat, centerAmericaLong)
        map.setRegion(MKCoordinateRegionMakeWithDistance(regionLocation, latitudinalDist, longitudinalDist), animated: true)
    }
    
    // MARK: IBActions
    
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
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        /*
        print("\n\ndeselecting\n\n")
        // makes sure that the user didn't select another pin (which will deselect this pin!)
        if mapView.selectedAnnotations.count > 0 {
            print("\n\nreturn\n\n")
            return
        }
        
        let urlString = (view.annotation as! MapPinAnnotation).subtitle
        if let url = URL(string: urlString!), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        } else {
            let alert = UIAlertController(title: "Invalid URL", message: "This student's media URL is invalid.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        */
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let mapPin = view.annotation as? MapPinAnnotation {
            let urlString = mapPin.subtitle
            if let url = URL(string: urlString!), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                let alert = UIAlertController(title: "Invalid URL", message: "This student's media URL is invalid.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /*
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let mapPin = view.annotation as? MapPinAnnotation {
            let urlString = mapPin.subtitle
            if let url = URL(string: urlString!), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            } else {
                let alert = UIAlertController(title: "Invalid URL", message: "This student's media URL is invalid.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("1")
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "selected pin")
        annotationView.canShowCallout = true
        
        let label = UILabel()
        label.frame.size.width = 50
        label.frame.size.height = 25
        label.backgroundColor = .red
        label.text = (annotation as! MapPinAnnotation).subtitle
        annotationView.detailCalloutAccessoryView = label
        
        print("2")
        return annotationView
    }
    */
}
