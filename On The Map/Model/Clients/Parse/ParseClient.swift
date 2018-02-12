//
//  ParseClient.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/11/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation

// MARK: - ParseClient: NSObject

class ParseClient: NSObject {
    
    // MARK: Properties
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    // shared session
    var session = URLSession.shared
    
    // data
    static var students: [MapPinAnnotation] = []
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    // create a URL from parameters
    func parseURLWithMethod(method: String) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + method
        
        return components.url!
    }
    
}
