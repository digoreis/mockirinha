//
//  URLSession.swift
//  
//
//  Created by Rodrigo Reis on 29/02/2024.
//

import Foundation

/// Extension for URLSession providing a convenient method for mocking responses during asynchronous requests.
///
/// This extension is available starting from iOS 13.0.
@available(iOS 13.0, *)
/// Mocks a response for a specific URL using the provided closure.
///
/// - Parameters:
///   - url: The URL to mock the response for.
///   - response: The mock response to be returned.
///   - configuration: The configuration for the URLSession. Defaults to `.ephemeral`.
///   - function: The name of the calling function. Defaults to the name of the caller.
///   - line: The line number where the function is called. Defaults to the line number of the caller.
///   - file: The file name where the function is called. Defaults to the file name of the caller.
///   - handle: A closure to handle the URLSession. Accepts a URLSession as a parameter and returns `Void` asynchronously.
///
/// Example usage:
///
/// ```
/// URLSession.mock(url: yourURL,
///                 response: .success(yourData, yourHTTPURLResponse),
///                 configuration: yourURLSessionConfiguration) async { session in
///     // Your custom logic to handle the mocked URLSession
///     // ...
/// }
/// ```
public func stub( response: Mockirinha.ResponseStrategy,
                  configuration: URLSessionConfiguration = .ephemeral,
                  function: StaticString = #function,
                  line: Int = #line,
                  file: StaticString = #file,
                  handle: (URLSession) async -> Void ) async {
    // Generate a unique key for the mock response
    let mockKey = Mockirinha.generateKey(function: function, line: line, file: file)
    // Configure a URLSession with the Mockirinha protocol and set the mock key in the header
    let session: URLSession = {
        configuration.protocolClasses = [Mockirinha.self]
        configuration.httpAdditionalHeaders = [Mockirinha.Constants.headerID : mockKey]
        return URLSession(configuration: configuration)
    }()
    // Store the mock response for the duration of the URLSession task
    Mockirinha.requestResponse[mockKey] = response
    // Execute the provided closure with the configured URLSession
    await handle(session)
    // Remove the stored mock response after the URLSession task is completed
    Mockirinha.requestResponse.removeValue(forKey: mockKey)
}
