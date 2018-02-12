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
    
    // MARK: Authentication Method
    
    func authenticateWith(_ username: String, _ password: String, authCompletionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        var request = URLRequest(url: udacityURLWithMethod(method: Methods.Session))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
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
            
            UdacityClient.sharedInstance().accountKey = accountKey
            UdacityClient.sharedInstance().sessionID = sessionID
            
            authCompletionHandler(true, nil)
        }
        
        task.resume()
    }
    
    // MARK: Load User Data Method
    
    func loadUserData(completionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        let request = URLRequest(url: udacityURLWithMethod(method: Methods.Users + "/\(UdacityClient.sharedInstance().accountKey!)"))
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode >= 200 && statusCode <= 299) else {
                completionHandler(false, "Your request returned a status code other than 2xx.")
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            guard let data = newData else {
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
            
            guard let userDict = parsedResult[JSONResponseKeys.User] as? [String:Any] else {
                completionHandler(false, "Could not parse the user JSON.")
                return
            }
            
            guard let firstName = userDict[JSONResponseKeys.FirstName] as? String else {
                completionHandler(false, "Could not parse the first name.")
                return
            }
            
            guard let lastName = userDict[JSONResponseKeys.LastName] as? String else {
                completionHandler(false, "Could not parse the last name.")
                return
            }
            
            guard let uniqueKey = userDict[JSONResponseKeys.UniqueKey] as? String else {
                completionHandler(false, "Could not parse the key.")
                return
            }
            
            ParseClient.sharedInstance().firstName = firstName
            ParseClient.sharedInstance().lastName = lastName
            ParseClient.sharedInstance().uniqueKey = uniqueKey
            
            completionHandler(true, nil)
        }
        
        task.resume()
    }
    
    // MARK: Logout Method
    
    func deleteSession(completionHandler: @escaping (_ success: Bool, _ errorString: String?)->Void) {
        var request = URLRequest(url: udacityURLWithMethod(method: Methods.Session))
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                completionHandler(false, error?.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (statusCode >= 200 && statusCode <= 299) else {
                completionHandler(false, "Your request returned a status code other than 2xx.")
                return
            }
            
            completionHandler(true, nil)
        }
        
        task.resume()
    }
    
}
