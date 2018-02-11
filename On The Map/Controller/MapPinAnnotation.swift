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
    //var uniqueKey: Int?
    var mapString: String?
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D/*, uniqueKey: Int?*/, mapString: String?) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        //self.uniqueKey = uniqueKey
        self.mapString = mapString
    }
    
}
