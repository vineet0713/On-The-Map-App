//
//  MapPinAnnotation.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/11/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation
import MapKit

class MapPinAnnotation: NSObject, MKAnnotation {
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var objectId: String?
    var uniqueKey: String?
    var mapString: String?
    
    // default initializer
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
    
    // failable initializer:
    init?(studentDict: [String:Any]) {
        guard let first = studentDict[ParseClient.JSONResponseKeys.FirstName] as? String else {
            return nil
        }
        guard let last = studentDict[ParseClient.JSONResponseKeys.LastName] as? String else {
            return nil
        }
        let studentTitle = "\(first) \(last)"
        
        guard let media = studentDict[ParseClient.JSONResponseKeys.MediaURL] as? String else {
            return nil
        }
        
        guard let lat = studentDict[ParseClient.JSONResponseKeys.Latitude] as? CLLocationDegrees else {
            return nil
        }
        guard let long = studentDict[ParseClient.JSONResponseKeys.Longitude] as? CLLocationDegrees else {
            return nil
        }
        let studentCoor = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        guard let objectId = studentDict[ParseClient.JSONResponseKeys.ObjectID] as? String else {
            return nil
        }
        
        guard let uniqueKey = studentDict[ParseClient.JSONResponseKeys.UniqueKey] as? String else {
            return nil
        }
        
        let mapString: String?
        if let string = studentDict[ParseClient.JSONResponseKeys.MapString] as? String {
            mapString = string
        } else {
            mapString = ""
        }
        
        self.title = studentTitle
        self.subtitle = media
        self.coordinate = studentCoor
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.mapString = mapString
    }
    
}
