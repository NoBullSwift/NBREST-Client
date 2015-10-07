import Foundation

// RestClient sync get
var dict = RestClient.get(
    hostname: "localhost",
    port: "8080",
    uri: "/AFTSurvey/entry/current",
    query: [
        "id": 1,
        "category": "user"
    ]).sendSync().getResponseBody()

for (key, value) in dict {
    println("\(key) => \(value)")
}

// RestClient async post
dict = RestClient.post(
    hostname: "localhost",
    port: "8080",
    uri: "/AFTSurvey/entry/vote",
    body: [
        "id": "test1",
        "rating": "10"
    ]).sendSync().getResponseBody()

for (key, value) in dict {
    println("\(key) => \(value)")
}