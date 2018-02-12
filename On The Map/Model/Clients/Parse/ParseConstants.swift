//
//  ParseConstants.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/11/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation

extension ParseClient {
    
    // MARK: Constants
    struct Constants {
        // MARK: Required Keys
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse"
    }
    
    // MARK: Methods
    struct Methods {
        // MARK: Classes
        static let Classes = "/classes"
        // MARK: Account
        static let StudentLocation = "/StudentLocation"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
    }
    
    // MARK: Parameter Values
    struct ParameterValues {
        static let GivenLimit = 100
        static let oldestToNewestAscending = "updatedAt"
        static let newestToOldestDescending = "-updatedAt"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        // MARK: Location
        static let Results = "results"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let UniqueKey = "uniqueKey"
        static let MapString = "mapString"
        static let httpBodyKeys = [UniqueKey, FirstName, LastName, MapString, MediaURL, Latitude, Longitude]
        static let ObjectID = "objectId"
        // MARK: Account
        static let AccountKey = "key"
    }
    
}
