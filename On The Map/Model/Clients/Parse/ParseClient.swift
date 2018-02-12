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
    
    var putPathExtension: String? = nil
    var updateLocationHTTPMethod: String? = nil
    
    // shared session
    var session = URLSession.shared
    
    // stored data
    var students: [MapPinAnnotation] = []
    
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
    
    // MARK: Helper Functions
    
    // create a URL from parameters
    func constructParseURL(method: String, parameters: [String:Any]?) -> URL {
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + method
        
        if let parameters = parameters {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    // create a HTTP Body from parameters
    func getHTTPBody(values: [String]) -> Data? {
        var httpBody = "{"
        
        for i in 0..<values.count {
            httpBody += ("\"" + JSONResponseKeys.httpBodyKeys[i] + "\": ")
            
            // if it isn't either latitude or longitude, add quotation marks around the value
            if i < (values.count - 2) {
                httpBody += ("\"" + values[i] + "\"")
            } else {
                httpBody += (values[i])
            }
            
            // if it isn't the last element, append a ", "
            if i != (values.count - 1) {
                httpBody += (", ")
            }
        }
        
        // add a closing brace '}'
        httpBody += ("}")
        
        return httpBody.data(using: .utf8)
    }
    
    // checks if the user has already posted a pin
    func userAlreadyPostedAPin() -> Bool {
        for student in students {
            if student.uniqueKey! == uniqueKey! {
                putPathExtension = "/\(student.objectId!)"
                updateLocationHTTPMethod = "PUT"
                return true
            }
        }
        putPathExtension = ""
        updateLocationHTTPMethod = "POST"
        return false
    }
    
}
