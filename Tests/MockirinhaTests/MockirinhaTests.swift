import XCTest
@testable import Mockirinha

final class MockirinhaTests: XCTestCase {
    func testSuccessfulRequestToGoogle() async throws {
        await stub(response: .unique(.url(URL(string: "https://google.com")!), .empty(.create))) { session in
            do {
                let (_, response) = try await session.data(from: URL(string: "https://google.com")!)
                if let httpResponse = response as?  HTTPURLResponse {
                    XCTAssertEqual(201,  httpResponse.statusCode)
                }
            } catch {
                XCTFail("Fail the request")
            }
        }
    }
    
    func testFailureRequestToGoogle() async throws {
        await stub(response: .unique(.url(URL(string: "https://google.com")!), .empty(.notFound))) { session in
            do {
                let (_, response) = try await session.data(from: URL(string: "https://google.com")!)
                if let httpResponse = response as?  HTTPURLResponse {
                    XCTAssertEqual(404,  httpResponse.statusCode)
                }
            } catch {
                XCTFail("Fail the request")
            }
        }
    }
    
    func testSuccessfulRequestToGoogleWithCustomPayload() async throws {
        let dataPayload = """
        test
        """.data(using: .utf8)!
        
        await stub(response: .unique(.url(URL(string: "https://google.com")!), .payload(.accepted, dataPayload))) { session in
            do {
                let (data, response) = try await session.data(from: URL(string: "https://google.com")!)
                if let httpResponse = response as?  HTTPURLResponse {
                    XCTAssertEqual(202,  httpResponse.statusCode)
                    XCTAssertEqual(dataPayload, data)
                }
            } catch {
                XCTFail("Fail the request")
            }
        }
    }
    
    func testSuccessfulRequestToGoogleAndBingInGroup() async throws {
        let group: Mockirinha.ResponseStrategy = .group([
            (strategy: .url(URL(string: "https://google.com")!), response: .empty(.ok)),
            (strategy: .url(URL(string: "https://bing.com")!), response: .empty(.notFound))
        ])
        await stub(response: group) { session in
            do {
                let (_, responseGoogle) = try await session.data(from: URL(string: "https://google.com")!)
                if let httpResponse = responseGoogle as?  HTTPURLResponse {
                    XCTAssertEqual(200,  httpResponse.statusCode)
                }
                
                let (_, responseBing) = try await session.data(from: URL(string: "https://bing.com")!)
                if let httpResponse = responseBing as?  HTTPURLResponse {
                    XCTAssertEqual(404,  httpResponse.statusCode)
                }
            } catch {
                XCTFail("Fail the request")
            }
        }
    }
    
    func testSuccessfulRequestWithMatchingURL() async throws {
        let regex = #"https:\/\/sample\.com\/product\/\d+"#
        
        await stub(response: .unique(.regex(regex), .empty(.create))) { session in
            do {
                let (_, response) = try await session.data(from: URL(string: "https://sample.com/product/1")!)
                if let httpResponse = response as?  HTTPURLResponse {
                    XCTAssertEqual(201,  httpResponse.statusCode)
                }
            } catch {
                XCTFail("Fail the request")
            }
        }
    }
    
    func testFailedRequestWithMatchingURL() async throws {
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
    }
    
    func testSuccessfulWithReport() async throws {
        let report = await stub(response: .unique(.url(URL(string: "https://google.com")!), .empty(.create))) { session in
            do {
                let (_, response) = try await session.data(from: URL(string: "https://google.com")!)
                if let httpResponse = response as?  HTTPURLResponse {
                    XCTAssertEqual(201,  httpResponse.statusCode)
                }
            } catch {
                XCTFail("Fail the request")
            }
        }
        XCTAssertEqual(report.requests.count, 1)
        XCTAssertEqual(report.requests[0].method, "GET")
        XCTAssertEqual(report.executedMock.count, 1)
        XCTAssertEqual(report.totalExecuted, 1)
    }
    
    func testSuccessfulInGroupWithPayload() async throws {
        let dataPayload = """
        test
        """.data(using: .utf8)!
        
        let group: Mockirinha.ResponseStrategy = .group([
            (strategy: .url(URL(string: "https://google.com")!), response: .payload(.accepted, dataPayload)),
        ])
        
        await stub(response: group) { session in
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
    }
}
