# Swift-REST-Client
An easy to use REST Client for Swift (as far as I can tell there aren't any)


# Dependencies
This library relies on SwiftyJSON.  To integrate, simply drag SwiftyJSON.swift from finder onto the project in XCode.  Then do the same with RestClient.swift

# Example

	// RestClient sync get
	var dict = RestClient.get(
		hostname: "localhost",
		port: "8080",
		uri: "/AFTSurvey/test",
		query: [
			"id": 1,
			"category": "user"
		]).sendSync().getResponseBody()

  // Print out returned JSON
	for (key, value) in dict {
		println("\(key) => \(value)")
	}

	// RestClient async get
	var client = RestClient.get(
		hostname: "localhost",
		port: "8080",
		uri: "/AFTSurvey/test",
		query: [
			"id": 1,
			"category": "user"
		]).sendAsync()

  //  Wait for completion of async call (you can also check client.isComplete())
	client.waitForCompletion()
  
  // Print out returned JSON
	for (key, value) in client.getResponseBody() {
		println("\(key) => \(value)")
	}
	
		// RestClient async post
	dict = RestClient.post(
		hostname: "localhost",
		port: "8080",
		uri: "/AFTSurvey/test/echo",
		body: [
			"color": "pink",
			"material": "cotton",
			"type": "shirt"
		]).sendSync()
		
Other HTTP methods are similar.  The only difference between GET and DELET from the others is that they have a query parameter instead of a body parameter.
