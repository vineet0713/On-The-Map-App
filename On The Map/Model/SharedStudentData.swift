//
//  SharedStudentData.swift
//  On The Map
//
//  Created by Vineet Joshi on 2/12/18.
//  Copyright © 2018 Vineet Joshi. All rights reserved.
//

import Foundation

class SharedStudentData {
    
    // MARK: Properties
    
    var students: [MapPinAnnotation] = []
    
    // MARK: Initializers
    
    private init() {}
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> SharedStudentData {
        struct Singleton {
            static var sharedInstance = SharedStudentData()
        }
        return Singleton.sharedInstance
    }
    
}
