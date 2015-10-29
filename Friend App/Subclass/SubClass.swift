//
//  SubClass.swift
//  Friend App
//
//  Created by Paul Galasso on 9/10/15.
//  Copyright (c) 2015 Mark Angeles. All rights reserved.
//

import Foundation
import UIKit


// MARK: - Webservice 
protocol WebserviceClassDelegate {
    
    func webserviceDidReceiveData(webservice: WebserviceClass, content: NSDictionary)
}

class WebserviceClass : NSObject , NSURLConnectionDelegate, NSURLConnectionDataDelegate{
    
    // MARK: Properties
    var link : String!
    var dataResponse : NSMutableData?
    var identifier : String!
    var connection: NSURLConnection?
    var request: NSMutableURLRequest?
    var statusCode: Int! = 0
    
    var delegate: WebserviceClassDelegate?
    override init() {
        
        self.link = ""
        self.dataResponse = nil
        self.identifier = ""
        
        
    }
    
    // MARK: Method
    // JSON Parameter
    func sendPostWithParameter(parameter : NSDictionary) {
    
        print(parameter)
        self.request = NSMutableURLRequest()
        self.request?.URL = NSURL(string: self.link)
        self.request?.HTTPMethod = "POST"
        self.request!.addValue("application/json", forHTTPHeaderField: "Content-Type")
        self.request!.addValue("application/json", forHTTPHeaderField: "Accept")
        self.request!.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(parameter, options: [])
        
        self.dataResponse = NSMutableData()
        
        self.connection = NSURLConnection(request: self.request!, delegate: self)
        
    }
    // JSON Parameter
    func sendPatchWithParameter(parameter : NSDictionary) {
        
        print(parameter)
        self.request = NSMutableURLRequest()
        self.request?.URL = NSURL(string: self.link)
        self.request?.HTTPMethod = "PATCH"
        self.request!.addValue("application/json", forHTTPHeaderField: "Content-Type")
        self.request!.addValue("application/json", forHTTPHeaderField: "Accept")
        self.request!.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(parameter, options: [])
        
        self.dataResponse = NSMutableData()
        
        self.connection = NSURLConnection(request: self.request!, delegate: self)
        
    }
    
    // String Parameter
    func sendPostWithStringParameter(parameter : NSDictionary) {
        
        var stringParameter = ""
        
        for (var count = 0; count < parameter.allKeys.count; count++) {
            let key = parameter.allKeys[count] as! String
            stringParameter = stringParameter.stringByAppendingFormat("\(key)=\(parameter[key] as! String)")
            if count != parameter.allKeys.count - 1 {
                stringParameter = stringParameter.stringByAppendingFormat("&")
            }
        }
        if stringParameter == "" {
            stringParameter = "---------------------------14737809831466499882746641449"
        }
        
       let dataParameter = stringParameter.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        
        self.request = NSMutableURLRequest()
        self.request?.URL = NSURL(string: self.link)
        self.request?.HTTPMethod = "POST"
        self.request?.setValue("\(dataParameter!.length)", forHTTPHeaderField: "Content-length")
        self.request?.HTTPBody = dataParameter!
        self.dataResponse = NSMutableData()
        
        self.connection = NSURLConnection(request: self.request!, delegate: self)
        
        
    }
    
    // String Parameter
    func getMethod(parameter : NSDictionary) {
        
     
        if parameter.allKeys.count != 0 {
            
            for (var count = 0; count < parameter.allKeys.count; count++){
                let key = parameter.allKeys[count] as! String
                let value = parameter[key] as! String
                self.link = self.link.stringByAppendingFormat("\(value)")
            }
            
        }
        
        print(self.link)
        
        self.request = NSMutableURLRequest()
        self.request?.URL = NSURL(string: self.link)
        self.request?.HTTPMethod = "GET"
        self.dataResponse = NSMutableData()
        
        self.connection = NSURLConnection(request: self.request!, delegate: self)
        
        
    }
    
    // MARK: Delegate
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.dataResponse = nil
        
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        self.dataResponse?.appendData(data)
        
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        
        let stringResponse = NSString(data: self.dataResponse!, encoding: NSUTF8StringEncoding)
        print(stringResponse, terminator: "")
        
        do {
            let anyObj = try NSJSONSerialization.JSONObjectWithData(self.dataResponse!, options: []) 
            // use anyObj here
            if anyObj.isKindOfClass(NSDictionary) == false {
                self.delegate?.webserviceDidReceiveData(self, content: NSDictionary())
                return
            }
            self.delegate?.webserviceDidReceiveData(self, content: anyObj as! NSDictionary)
        } catch {
            let dictionaryReturn = NSMutableDictionary()
            dictionaryReturn.setObject("failed", forKey: "status")
            self.delegate?.webserviceDidReceiveData(self, content: dictionaryReturn)
        }
        
        
        
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        
        let responseHTTP = response as! NSHTTPURLResponse
        self.statusCode = responseHTTP.statusCode
        
        
    }

}

// MARK: - Local Notif

