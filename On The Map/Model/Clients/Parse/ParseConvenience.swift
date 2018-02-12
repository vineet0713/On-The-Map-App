//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/11/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation
import MapKit

extension ParseClient {
    
    // MARK: Get Locations Method
    
    func getLocations(completionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        let method = Methods.Classes + Methods.StudentLocation
        let parameters: [String:Any] = [ParameterKeys.Limit: ParameterValues.GivenLimit,
                                        ParameterKeys.Order: ParameterValues.newestToOldestDescending]
        
        var request = URLRequest(url: constructParseURL(method: method, parameters: parameters))
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode >= 200 && statusCode <= 299) else {
                completionHandler(false, "Your request returned a status code other than 2xx.")
                return
            }
            
            guard let data = data else {
                completionHandler(false, "No data was returned.")
                return
            }
            
            var parsedResult: [String:Any]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            } catch {
                completionHandler(false, "Could not parse the data as JSON.")
                return
            }
            
            guard let arrayOfStudentDicts = parsedResult[JSONResponseKeys.Results] as? [[String:Any]] else {
                completionHandler(false, "Could not parse the data as array of dictionaries.")
                return
            }
            
            SharedStudentData.sharedInstance().students = []
            for student in arrayOfStudentDicts {
                if let studentAnnotation = MapPinAnnotation(studentDict: student) {
                    SharedStudentData.sharedInstance().students.append(studentAnnotation)
                } else {
                    completionHandler(false, "Could not parse the data from the student JSON.")
                }
            }
            
            completionHandler(true, nil)
        }
        
        task.resume()
    }
    
    // MARK: POST/PUT Method for Locations
    
    func updateLocation(httpBodyDictValues: [String], completionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        let method = Methods.Classes + Methods.StudentLocation + putPathExtension!
        // no parameters to pass!
        
        var request = URLRequest(url: constructParseURL(method: method, parameters: nil))
        request.httpMethod = updateLocationHTTPMethod!
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = getHTTPBody(values: httpBodyDictValues)
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            completionHandler(true, nil)
        }
        
        task.resume()
    }
    
}
