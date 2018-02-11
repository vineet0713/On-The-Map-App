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
    
    func getLocations(authCompletionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        var request = URLRequest(url: URL(string: Constants.BaseURL + Methods.StudentLocation)!)
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                authCompletionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode >= 200 && statusCode <= 299) else {
                authCompletionHandler(false, "Your request returned a status code other than 2xx.")
                return
            }
            
            guard let data = data else {
                authCompletionHandler(false, "No data was returned.")
                return
            }
            
            var parsedResult: [String:Any]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            } catch {
                authCompletionHandler(false, "Could not parse the data as JSON.")
                return
            }
            // print(parsedResult)
            
            guard let arrayOfStudentDicts = parsedResult["results"] as? [[String:Any]] else {
                authCompletionHandler(false, "Could not parse the data as array of dictionaries.")
                return
            }
            
            ParseClient.students = []
            for student in arrayOfStudentDicts {
                guard let first = student["firstName"] as? String, let last = student["lastName"] as? String else {
                    authCompletionHandler(false, "Could not parse the first and last names from the student JSON.")
                    return
                }
                guard let media = student["mediaURL"] as? String else {
                    authCompletionHandler(false, "Could not parse the media URL from the student JSON.")
                    return
                }
                guard let lat = student["latitude"] as? CLLocationDegrees else {
                    authCompletionHandler(false, "Could not parse the latitude from the student JSON.")
                    return
                }
                guard let long = student["longitude"] as? CLLocationDegrees else {
                    authCompletionHandler(false, "Could not parse the longitude from the student JSON.")
                    return
                }
                /*guard let uniqueKey = student["uniqueKey"] as? Int else {
                    authCompletionHandler(false, "Could not parse the unique key from the student JSON.")
                    return
                }*/
                let mapString: String?
                if let string = student["mapString"] as? String {
                    mapString = string
                } else {
                    mapString = ""
                }
                
                let studentTitle = "\(first) \(last)"
                let studentCoor = CLLocationCoordinate2D(latitude: lat, longitude: long)
                ParseClient.students.append(MapPinAnnotation(title: studentTitle, subtitle: media, coordinate: studentCoor, mapString: mapString))
            }
            
            authCompletionHandler(true, nil)
        }
        
        task.resume()
    }
    
}
