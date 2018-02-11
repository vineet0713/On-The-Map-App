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
    // represents 5 million meters, or 5 thousand kilometers
    let fiveMillionM: CLLocationDistance = 5000000
    
    /*
    var selectedPin: MKAnnotation? = nil
    */
    
    // MARK: Outlets
    
    @IBOutlet weak var map: MKMapView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateLocations()
    }
    
    func updateLocations() {
        ParseClient.sharedInstance().getLocations { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    let regionLocation = CLLocationCoordinate2DMake(self.centerAmericaLat, self.centerAmericaLong)
                    self.map.setRegion(MKCoordinateRegionMakeWithDistance(regionLocation, self.fiveMillionM, self.fiveMillionM), animated: true)
                    self.map.addAnnotations(ParseClient.students)
                }
            } else {
                print(errorString!)
            }
        }
    }
    
    // MARK: IBActions
    
    @IBAction func postPin(_ sender: Any) {
        print("Map Post Pin")
    }
    
    @IBAction func refresh(_ sender: Any) {
        updateLocations()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
