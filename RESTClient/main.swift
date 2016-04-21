import Foundation

func displayResponse(response: NBRestResponse) {
    print("Status Code: \(response.statusCode)")
    print("Headers:")
    for (key, value) in response.headers {
        print("\t\(key): \(value)")
    }
    
    print("Body:")
    NBJSON.Utils.printObject(response.body, tabs: 1)
}

// Setup default object mappers
NBRestClient.setupDefaults()

// RestClient get test
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

var response : NBRestResponse = postRequest.sendSync()
displayResponse(response)

// RestClient get test
var getRequest = NBRestClient.get(
    hostname: "localhost",
    port: "8080",
    uri: "/collectamundo/v1/collectables"
    )

// Set content and accept types
getRequest.setContentType(NBRestClient.NBMediaType.APPLICATION_JSON)
getRequest.setAcceptType(NBRestClient.NBMediaType.APPLICATION_JSON)

// Test Sync Call
response = getRequest.sendSync()
displayResponse(response)

// Test Async Call
getRequest.sendAsync({(response: NBRestResponse!) -> Void in
    displayResponse(response)
})
getRequest.waitForCompletion()