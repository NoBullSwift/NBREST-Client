# NBREST-Client
No Bull Rest Client.  Make rest calls with ease.  This class is an abstraction of NSURLConnection and offers advanced features such as object mapper injection (for serializing and deserializing objects to/from JSON, XML, and other common mime types).

# Dependencies
This library depends on NBJSON, the No Bull JSON parser.  Just include NBJSON.swift in your project.

# Example

## POST Request Example (with synchronous call)
	// Setup default object mappers
	NBRestClient.setupDefaults()

    // Create POST request
    var postRequest = NBRestClient.post(
		hostname: "localhost",
		port: "8080",
		uri: "/collectamundo/v1/collectables",
		body: [
			"name": "Super Street Fighter II"
		]
	)

    postRequest.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
    postRequest.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)

    // Send request synchronously
    var response : NBRestResponse = postRequest.sendSync()
    print("Status Code: \(response.statusCode)")
    print("Headers:")
    for (key, value) in response.headers {
    	print("\t\(key): \(value)")
    }

## GET Request Example (with asynchronous call)
    // Setup default object mappers
    NBRestClient.setupDefaults()
	
    // Create GET request
    var getRequest = NBRestClient.get(
        hostname: "localhost",
        port: "8080",
        uri: "/collectamundo/v1/collectables"
        )

    // Set content and accept types
    getRequest.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
    getRequest.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)

    // Send request asynchronously
    getRequest.sendAsync({(response: NBRestResponse!) -> Void in
        print("Status Code: \(response.statusCode)")
        print("Headers:")
        for (key, value) in response.headers {
            print("\t\(key): \(value)")
        }
    })
		
Other HTTP methods are similar.  The only difference between GET and DELETE from the others is that they have a query parameter instead of a body parameter.
