# Mockirinha

`Mockirinha` is a Swift library that provides utilities for mocking responses during URLSession requests. It includes a custom `URLProtocol` and an extension for `URLSession` to simplify the process of mocking responses for unit testing.

The name "Mockirinha" is a playful amalgamation of "Mock" and "Caipirinha." It draws inspiration from the popular Java testing framework "Mockito" while infusing a touch of Brazilian culture with the reference to "Caipirinha," a traditional Brazilian cocktail.

**Note: This library is experimental and intended for use in test targets only.**

## Features

- Mock responses for specific URLs during asynchronous requests.
- Easily configure URLSession to use the Mockirinha protocol.

## Installation

To install `Mockirinha` using Swift Package Manager, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/seuusuario/Mockirinha.git", .branch("main"))
],
targets: [
    .target(
        name: "YourTarget"),
    .testTarget(
        name: "YourTests",
        dependencies: ["YourTarget", "Mockirinha"]),
]
```

## Usage

### Mocking URLSession Responses

```swift
import Mockirinha

// Example of mocking a successful response
await stub(response: .unique(.url(yourURL), .payload(.accepted, yourPayload))) { session in
    // Your custom logic to handle the mocked URLSession
    // ...
}
```

### More samples
```swift
await stub(response: .unique(.url(URL(string: "https://google.com")!), .empty(.create))) { session in
    do {
        let (_, response) = try await session.data(from: URL(string: "https://google.com")!)
        if let httpResponse = response as?  HTTPURLResponse {
            XCTAssertEqual(201,  httpResponse.statusCode)
        } else {
            XCTFail("HTTP code invalid")
        }
    } catch {
        XCTFail("Fail the request")
    }
}
```
```swift
await stub(response: .unique(.url(URL(string: "https://google.com")!), .empty(.notFound))) { session in
    do {
        let (_, response) = try await session.data(from: URL(string: "https://google.com")!)
        if let httpResponse = response as?  HTTPURLResponse {
            XCTAssertEqual(404,  httpResponse.statusCode)
        } else {
            XCTFail("HTTP code invalid")
        }
    } catch {
        XCTFail("Fail the request")
    }
}
```
```swift
let dataPayload = """
test
""".data(using: .utf8)!

await stub(response: .unique(.url(URL(string: "https://google.com")!), .payload(.accepted, dataPayload))) { session in
    do {
        let (data, response) = try await session.data(from: URL(string: "https://google.com")!)
        if let httpResponse = response as?  HTTPURLResponse {
            XCTAssertEqual(202,  httpResponse.statusCode)
            XCTAssertEqual(dataPayload, data)
        } else {
            XCTFail("HTTP code invalid")
        }
    } catch {
        XCTFail("Fail the request")
    }
}
```
```swift
let group: Mockirinha.ResponseStrategy = .group([
    (strategy: .url(URL(string: "https://google.com")!), response: .empty(.ok)),
    (strategy: .url(URL(string: "https://bing.com")!), response: .empty(.notFound))
])
await stub(response: group) { session in
    do {
        let (_, responseGoogle) = try await session.data(from: URL(string: "https://google.com")!)
        if let httpResponse = responseGoogle as?  HTTPURLResponse {
            XCTAssertEqual(200,  httpResponse.statusCode)
        } else {
            XCTFail("HTTP code invalid")
        }

        let (_, responseBing) = try await session.data(from: URL(string: "https://bing.com")!)
        if let httpResponse = responseBing as?  HTTPURLResponse {
            XCTAssertEqual(404,  httpResponse.statusCode)
        } else {
            XCTFail("HTTP code invalid")
        }
    } catch {
        XCTFail("Fail the request")
    }
}
```
```swift
let regex = #"https:\/\/sample\.com\/product\/\d+"#

await stub(response: .unique(.regex(regex), .empty(.create))) { session in
    do {
        let (_, response) = try await session.data(from: URL(string: "https://sample.com/product/1")!)
        if let httpResponse = response as?  HTTPURLResponse {
            XCTAssertEqual(201,  httpResponse.statusCode)
        } else {
            XCTFail("HTTP code invalid")
        }
    } catch {
        XCTFail("Fail the request")
    }
}
```
```swift
let regex = #"https:\/\/sample\.com\/product\/\d+"#

let error = NSError(domain: "com.mockirinha", code: -1001)

await stub(response: .unique(.regex(regex), .error(error))) { session in
    do {
        let (_, _) = try await session.data(from: URL(string: "https://sample.com/product/1")!)
        XCTFail("HTTP code invalid")
    } catch {
        XCTAssertEqual((error as NSError).code, -1001)
    }
}
```
## Requirements
* iOS 13.0+
## License
This project is licensed under the MIT License - see the LICENSE file for details.