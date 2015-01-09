import Foundation

// RestClient sync get
var dict = RestClient.get(
    hostname: "localhost",
    port: "8080",
    uri: "/AFTSurvey/test",
    query: [
        "id": 1,
        "category": "user"
    ]).sendSync().getResponseBody()

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

client.waitForCompletion()

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
    ]).sendSync().getResponseBody()

for (key, value) in dict {
    println("\(key) => \(value)")
}