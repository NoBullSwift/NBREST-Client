//
//  RestClient.swift
//  REST-Test
//
//  Created by Michael Main on 1/8/15.
//  Copyright (c) 2015 Michael Main. All rights reserved.
//

import Foundation

func createQueryString(pairs: Dictionary<String, AnyObject>) -> String {
    var query = ""
    var sep = "?"
    
    for (key, value) in pairs {
        query += "\(sep)\(key)=\(value)"
        sep = "&"
    }
    
    return query
}

enum ObjectMapperError : ErrorType {
    case NoObjectMapper
}

class NBRestResponse {
    var response : NSHTTPURLResponse?
    var statusCode : Int!
    var contentType : String!
    var headers : Dictionary<String, String>! = [:]
    var body : Any!
    var error : NSError?
    
    init(statusCode: Int, contentType: String, headers: Dictionary<String, String>, body: Any) {
        self.statusCode = statusCode
        self.contentType = contentType
        self.headers = headers
        self.body = body
    }
    
    init(response: NSHTTPURLResponse, data: NSData?) {
        let responseString : String = String(data: data!, encoding: NSUTF8StringEncoding)!
        do {
            self.response = response
            self.statusCode = response.statusCode
            self.contentType = response.allHeaderFields["Content-Type"] as? String
            self.body = try NBRestClient.consumeResponse(self.contentType!, responseBody: responseString)
            
            for (key, value) in response.allHeaderFields {
                headers[key as! String] = value as? String
            }
        } catch let error as NSError {
            print(error)
            self.error = error
        }
    }
}

class NBRestRequest {
    var request : NSMutableURLRequest = NSMutableURLRequest()
    var contentType: String?
    var acceptType: String?
    var response : NBRestResponse?
    var headers : Dictionary<String, String> = [:]
    var error : NSError!
    
    var completed : Bool = false
    
    init(method: String, hostname : String, port : String, uri : String, headers : Dictionary<String, String>, body : Dictionary<String, AnyObject> = [:], ssl : Bool) {
        var url = "http://"
        
        if (ssl) {
            url = "https://"
        }
        
        url += hostname
        
        if (!port.isEmpty) {
            url += ":\(port)"
        }
        
        url += uri
        
        if (!body.isEmpty) {
            if (method != "GET" && method != "DELETE") {
                let json = NBJSON.Parser.stringify(body)
                request.HTTPBody = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                addHeader("Content-Length", value: "\(json.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))")
            } else {
                url += createQueryString(body)
            }
        }
        
        request.URL = NSURL(string: url)
        request.HTTPMethod = method
        
        for (key, value) in headers {
            addHeader(key, value: value)
        }
    }
    
    func addHeader(key : String, value : String) -> NBRestRequest {
        if (key == "Content-Type") {
            contentType = value
        } else if (key == "Accept") {
            acceptType = value
        }
        
        headers[key] = value
        return self
    }
    
    func setContentType(contentType: String) -> NBRestRequest {
        self.contentType = contentType
        return self
    }
    
    func setAcceptType(acceptType: String) -> NBRestRequest {
        self.acceptType = acceptType
        return self
    }
    
    private func setupHeaders() {
        if (contentType == nil) {
            contentType = "*/*"
        }
        
        request.addValue(contentType!, forHTTPHeaderField: "Content-Type")
        
        if (acceptType != nil) {
            acceptType = "*/*"
        }
        
        request.addValue(acceptType!, forHTTPHeaderField: "Accept")
        
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
    }
    
    func sendSync() -> NBRestResponse! {
        setupHeaders()
        self.response = nil
        self.completed = false
        
        do {
            var urlResponse : NSURLResponse?
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &urlResponse)
            let httpResponse: NSHTTPURLResponse = urlResponse as! NSHTTPURLResponse
            self.response = NBRestResponse(response: httpResponse, data: data)
            self.completed = true
            
            return self.response
        } catch let error as NSError {
            print(error.description)
            self.error = error
            return nil
        }
    }
    
    func sendAsync() -> Void {
        sendAsync({(response: NBRestResponse!) -> Void in
        })
    }
    
    func sendAsync(completionHandler: ((response : NBRestResponse!) -> Void)) -> Void {
        self.response = nil
        self.completed = false
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: { (response:NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if (error != nil || data == nil) {
                print("ERROR: \(error?.description)")
                self.response = nil
                self.completed = true
                self.error = error
                return
            }
            
            let httpResponse: NSHTTPURLResponse = response as! NSHTTPURLResponse
            
            self.response = NBRestResponse(response: httpResponse, data: data)
            completionHandler(response: self.response)
            self.completed = true
        })
    }
    
    func isComplete() -> Bool {
        return completed
    }
    
    func waitForCompletion() {
        while !completed {}
    }
    
    func getResponse() -> Any? {
        return response
    }
}

class NBRestClient {
    static var objectMappers: Dictionary<String, NBObjectMapper> = [:]
    class NBMediaType {
        static var APPLICATION_JSON = "application/json"
        static var APPLICATION_XML = "application/xml"
    }
    
    class func setupDefaults() {
        addObjectMapperFor(NBMediaType.APPLICATION_JSON, mapper: NBJSON.NBOJSONbjectMapper())
    }
    
    class func consumeResponse(contentType: String, responseBody: String) throws -> Any? {
        let objectMapper = NBRestClient.getObjectMapperFor(contentType)
        
        guard objectMapper != nil else { throw ObjectMapperError.NoObjectMapper }
        
        return objectMapper?.deserialize(responseBody)
    }
    
    class func get(hostname hostname : String, port : String = "", uri : String, headers : Dictionary<String, String> = [:], query : Dictionary<String, AnyObject> = [:], ssl : Bool = false) -> NBRestRequest {
        return NBRestRequest(method: "GET", hostname: hostname, port: port, uri: uri, headers: headers, body: query, ssl: ssl)
    }
    
    class func put(hostname hostname : String, port : String = "", uri : String, headers : Dictionary<String, String> = [:], body : Dictionary<String, AnyObject> = [:], ssl : Bool = false) -> NBRestRequest {
        return NBRestRequest(method: "PUT", hostname: hostname, port: port, uri: uri, headers: headers, body: body, ssl: ssl)
    }
    
    class func post(hostname hostname : String, port : String, uri : String, headers : Dictionary<String, String> = [:], body : Dictionary<String, AnyObject> = [:], ssl : Bool = false) -> NBRestRequest {
        return NBRestRequest(method: "POST", hostname: hostname, port: port, uri: uri, headers: headers, body: body, ssl: ssl)
    }
    
    class func delete(hostname hostname : String, port : String, uri : String, headers : Dictionary<String, String> = [:], query : Dictionary<String, AnyObject> = [:], ssl : Bool = false) -> NBRestRequest {
        return NBRestRequest(method: "DELETE", hostname: hostname, port: port, uri: uri, headers: headers, body: query, ssl: ssl)
    }
    
    class func addObjectMapperFor(mimeType: String, mapper: NBObjectMapper) {
        objectMappers[mimeType] = mapper
    }
    
    class func getObjectMapperFor(mimeType: String) -> NBObjectMapper? {
        return objectMappers[mimeType]
    }
}