//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/10/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    func authenticateWith(_ username: String, _ password: String, authCompletionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                authCompletionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode >= 200 && statusCode <= 299) else {
                authCompletionHandler(false, "Your request returned a status code other than 2xx.")
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            guard let data = newData else {
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
            
            guard let accountDict = parsedResult[JSONResponseKeys.Account] as? [String:Any] else {
                authCompletionHandler(false, "Could not parse account JSON.")
                return
            }
            
            guard let sessionDict = parsedResult[JSONResponseKeys.Session] as? [String:Any] else {
                authCompletionHandler(false, "Could not parse session JSON.")
                return
            }
            
            guard let registered = accountDict[JSONResponseKeys.Registered] as? Bool, (registered == true) else {
                authCompletionHandler(false, "User is not registered.")
                return
            }
            
            guard let accountKey = accountDict[JSONResponseKeys.AccountKey] as? String else {
                authCompletionHandler(false, "Could not parse account key.")
                return
            }
            
            guard let sessionID = sessionDict[JSONResponseKeys.SessionID] as? String else {
                authCompletionHandler(false, "Could not parse session ID.")
                return
            }
            
            UdacityClient.accountKey = accountKey
            UdacityClient.sessionID = sessionID
            
            authCompletionHandler(true, nil)
        }
        
        task.resume()
    }
    
}