// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import XCTest

extension Mockirinha {
    
    public enum MatchStrategy {
        case regex(String)
        case url(URL)
    }
    
    public enum ResponseStrategy {
        case unique(MatchStrategy, Response)
        case group([(strategy: MatchStrategy,response: Response)])
    }
}

/// `Mockirinha` is a custom URLProtocol for mocking responses during URLSession requests.
@available(iOS 13.0, *)
public class Mockirinha: URLProtocol {
    
    /// Constants used within the `Mockirinha` class.
    enum Constants {
        /// Header identifier for mock responses.
        static let headerID = "mockirinha-id"
    }
    /// Dictionary to store request-response mappings.
    static var requestResponse: [String: ResponseStrategy] = [:]
    
    /// Returns a Boolean value indicating whether the protocol can handle the given request.
    ///
    /// - Parameter request: The URL request to be handled.
    /// - Returns: `true` if the protocol can handle the request; otherwise, `false`.
    public override class func canInit(with request: URLRequest) -> Bool {
        guard let mockKey = request.allHTTPHeaderFields?[Constants.headerID] else { return false }
        let result = Self.requestResponse.contains { key, responseStrategy in
            if let url = request.url, key == mockKey {
                switch(responseStrategy) {
                    case .unique(let strategy, _):
                        return matchStrategyKeyWithURL(strategy: strategy, requestURL: url)
                    case .group(let groups):
                        return groups.contains(where: { (matchStrategy, _) in
                            return matchStrategyKeyWithURL(strategy: matchStrategy, requestURL: url)
                        })
                }
            }
            return false
        }
        return result
    }
    /// Returns a canonical version of the specified request.
    ///
    /// - Parameter request: The URL request to be canonicalized.
    /// - Returns: The canonicalized URL request
    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    /// Starts the protocol-specific loading of a request.
   ///
   /// - Important: This method should be overridden to provide the custom response handling logic.
    public override func startLoading() {
        guard let url = self.request.url,let mockKey = request.allHTTPHeaderFields?[Constants.headerID] , let responseStrategy = Self.requestResponse[mockKey] else {
            XCTFail("Don't exist a mock for the \(self.request.url?.absoluteString ?? "")")
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        switch(responseStrategy) {
        case .unique(let strategy, let response):
            if Self.matchStrategyKeyWithURL(strategy: strategy, requestURL: url) {
                switch(response) {
                case .empty(let code):
                    guard let response = HTTPURLResponse(url: url, statusCode: code.rawValue, httpVersion: nil, headerFields: nil) else {
                        return
                    }
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                case .error(let error):
                    client?.urlProtocol(self, didFailWithError: error)
                case .payload(let code, let data):
                    guard let response = HTTPURLResponse(url: url, statusCode: code.rawValue, httpVersion: nil, headerFields: nil) else {
                        return
                    }
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
            }
        case .group(let groups):
            for g in groups {
                if Self.matchStrategyKeyWithURL(strategy: g.strategy, requestURL: url) {
                    switch(g.response) {
                    case .empty(let code):
                        guard let response = HTTPURLResponse(url: url, statusCode: code.rawValue, httpVersion: nil, headerFields: nil) else {
                            return
                        }
                        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    case .error(let error):
                        client?.urlProtocol(self, didFailWithError: error)
                    case .payload(let code, let data):
                        guard let response = HTTPURLResponse(url: url, statusCode: code.rawValue, httpVersion: nil, headerFields: nil) else {
                            return
                        }
                        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                        client?.urlProtocol(self, didLoad: data)
                    }
                    client?.urlProtocolDidFinishLoading(self)
                }
            }
        }
        
        
    }
    
    private class func matchStrategyKeyWithURL(strategy: MatchStrategy, requestURL: URL) -> Bool {
        switch(strategy) {
        case .regex(let urlRegex):
            do {
                let regex = try NSRegularExpression(pattern: urlRegex, options: .caseInsensitive)
                let matches = regex.matches(in: requestURL.absoluteString, options: [], range: NSRange(location: 0, length: requestURL.absoluteString.utf16.count))
                return !matches.isEmpty
            } catch {
                print("Error creating regex: \(error)")
                return false
            }
        case .url(let url):
            return url.absoluteString == requestURL.absoluteString
        }
    }
    // Stops the protocol-specific loading of a request.
    ///
    /// - Important: This method can be overridden to implement any necessary cleanup.
    public override func stopLoading() {
    
    }
}
