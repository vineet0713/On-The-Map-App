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
    
    func getLocations(completionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        var request = URLRequest(url: parseURLWithMethod(method: Methods.Classes + Methods.StudentLocation))
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
            print(parsedResult)
            
            guard let arrayOfStudentDicts = parsedResult[JSONResponseKeys.Results] as? [[String:Any]] else {
                completionHandler(false, "Could not parse the data as array of dictionaries.")
                return
            }
            
            ParseClient.students = []
            for student in arrayOfStudentDicts {
                guard let first = student[JSONResponseKeys.FirstName] as? String, let last = student[JSONResponseKeys.LastName] as? String else {
                    completionHandler(false, "Could not parse the first and last names from the student JSON.")
                    return
                }
                guard let media = student[JSONResponseKeys.MediaURL] as? String else {
                    completionHandler(false, "Could not parse the media URL from the student JSON.")
                    return
                }
                guard let lat = student[JSONResponseKeys.Latitude] as? CLLocationDegrees else {
                    completionHandler(false, "Could not parse the latitude from the student JSON.")
                    return
                }
                guard let long = student[JSONResponseKeys.Longitude] as? CLLocationDegrees else {
                    completionHandler(false, "Could not parse the longitude from the student JSON.")
                    return
                }
                /*guard let uniqueKey = student["uniqueKey"] as? Int else {
                    authCompletionHandler(false, "Could not parse the unique key from the student JSON.")
                    return
                }*/
                let mapString: String?
                if let string = student[JSONResponseKeys.MapString] as? String {
                    mapString = string
                } else {
                    mapString = ""
                }
                
                let studentTitle = "\(first) \(last)"
                let studentCoor = CLLocationCoordinate2D(latitude: lat, longitude: long)
                ParseClient.students.append(MapPinAnnotation(title: studentTitle, subtitle: media, coordinate: studentCoor, mapString: mapString))
            }
            
            completionHandler(true, nil)
        }
        
        task.resume()
    }
    
    func postLocation(httpBodyDictValues: [String], completionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        var request = URLRequest(url: parseURLWithMethod(method: Methods.Classes + Methods.StudentLocation))
        request.httpMethod = "POST"
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = getHTTPBody(values: httpBodyDictValues)
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandler(false, error?.localizedDescription)
                return
            }
            print(String(data: data!, encoding: .utf8)!)
            
            completionHandler(true, nil)
        }
        
        task.resume()
    }
    
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
    
}
