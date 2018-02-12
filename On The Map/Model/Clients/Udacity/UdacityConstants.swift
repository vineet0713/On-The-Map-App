//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/10/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation

// MARK: - UdacityClient (Constants)

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
        static let AccountURL = "https://www.themoviedb.org/account/"
    }
    
    // MARK: Methods
    struct Methods {
        // MARK: Session
        static let Session = "/session"
        // MARK: Users
        static let Users = "/users"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        // MARK: Authentication
        static let Account = "account"
        static let Session = "session"
        static let Registered = "registered"
        static let AccountKey = "key"
        static let SessionID = "id"
        // MARK: Get User Information
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let UniqueKey = "key"
    }
    
}
