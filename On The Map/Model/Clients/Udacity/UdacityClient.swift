//
//  UdacityClient.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/10/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation

// MARK: - UdacityClient: NSObject

class UdacityClient: NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // authentication state
    // var requestToken: String? = nil
    var accountKey: String? = nil
    var sessionID: String? = nil
    // var userID: Int? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
    // create a URL from parameters
    func udacityURLWithMethod(method: String) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + method
        
        return components.url!
    }
    
}
