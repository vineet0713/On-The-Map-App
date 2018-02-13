//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/11/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController {
    
    // MARK: Properties
    
    let topFieldTag = 0
    let bottomFieldTag = 1
    var bottomEditing = false
    
    var latitude: String? = nil
    var longitude: String? = nil
    
    // sets the latitudinal and longitudinal distances (for setting map region)
    let latitudinalDist: CLLocationDistance = 500
    let longitudinalDist: CLLocationDistance = 500
    
    // MARK: IBOutlets
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var geocodingIndicator: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationField.delegate = self
        linkField.delegate = self
        addButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        self.geocodingIndicator.alpha = CGFloat(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: IBActions
    
    @IBAction func findOnMap(_ sender: Any?) {
        locationField.resignFirstResponder()
        linkField.resignFirstResponder()
        
        if locationField.text == "" {
            showAlert(title: "Empty Location Field", message: "Please enter a location to search.")
        } else {
            performSearch(query: locationField.text!)
        }
    }
    
    @IBAction func addPin(_ sender: Any) {
        linkField.resignFirstResponder()
        
        if mediaLinkIsValid(mediaLink: linkField.text!) == false {
            showAlert(title: "Invalid Media URL", message: "Your media URL was invalid.")
            linkField.text = ""
            updateAddButtonEnabled()
        } else {
            // create the HTTP Body values for the POST method
            let sharedParseClient = ParseClient.sharedInstance()
            let httpBodyValues: [String] = [sharedParseClient.uniqueKey!, sharedParseClient.firstName!, sharedParseClient.lastName!,
                                  locationField.text!, linkField.text!, latitude!, longitude!]
            
            // add the pin!
            sharedParseClient.updateLocation(httpBodyDictValues: httpBodyValues, completionHandler: { (success, errorString) in
                performUIUpdatesOnMain {
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.showAlert(title: "Could Not Add Pin", message: errorString!)
                    }
                }
            })
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper Functions
    
    func updateAddButtonEnabled() {
        addButton.isEnabled = (locationField.text != "" && linkField.text != "")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func performSearch(query: String) {
        toggleGeocodingIndicator(turnOn: true)
        
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = query
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            if response == nil {
                self.toggleGeocodingIndicator(turnOn: false)
                self.showAlert(title: "Invalid Search", message: "Your search query was invalid.")
                self.locationField.text = ""
                self.updateAddButtonEnabled()
                return
            }
            
            // clears the current annotations from the map
            let currentAnnotations = self.map.annotations
            self.map.removeAnnotations(currentAnnotations)
            
            // get the data
            let latitude = response!.boundingRegion.center.latitude
            let longitude = response!.boundingRegion.center.longitude
            
            // save the latitude and longitude
            self.latitude = "\(latitude)"
            self.longitude = "\(longitude)"
            
            // create the annotation
            let newAnnotation = MKPointAnnotation()
            newAnnotation.title = query
            newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.map.addAnnotation(newAnnotation)
            
            // zoom in on annotation location
            let regionLocation = CLLocationCoordinate2DMake(latitude, longitude)
            self.map.setRegion(MKCoordinateRegionMakeWithDistance(regionLocation, self.latitudinalDist, self.longitudinalDist), animated: true)
            
            self.toggleGeocodingIndicator(turnOn: false)
        }
    }
    
    func mediaLinkIsValid(mediaLink: String) -> Bool {
        if let url = URL(string: mediaLink), UIApplication.shared.canOpenURL(url) {
            return true
        } else {
            return false
        }
    }
    
    func toggleGeocodingIndicator(turnOn: Bool) {
        if turnOn {
            geocodingIndicator.alpha = CGFloat(1)
            geocodingIndicator.startAnimating()
        } else {
            geocodingIndicator.stopAnimating()
            geocodingIndicator.alpha = CGFloat(0)
        }
    }
    
}

// MARK: UITextFieldDelegate

extension AddPinViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // sets the bottomEditing variable to true if the user begins editing the bottom TextField
        bottomEditing = (textField.tag == bottomFieldTag)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.tag == topFieldTag {
            findOnMap(nil)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAddButtonEnabled()
    }
    
}

// MARK: Keyboard Notifications

extension AddPinViewController {
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomEditing {
            // moves the View up by the height of the keyboard: (so the keyboard won't cover up the content!)
            self.view.frame.origin.y = self.getKeyboardHeight(notification) * -1
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomEditing {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue  // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
}
