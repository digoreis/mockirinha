//
//  File.swift
//  
//
//  Created by Rodrigo Reis on 01/03/2024.
//

import Foundation

public struct MockirinhaRequestReport {
    let url: URL?
    let headers: [AnyHashable: String]?
    let payload: Data?
    let method: String?
}

public struct MockirinhaReport {
    let requests: [MockirinhaRequestReport]
    let executedMock: [Mockirinha.MatchStrategy: Int]
    
    var totalExecuted: Int {
        return executedMock.reduce(0) { partialResult, value in
            return partialResult + value.value
        }
    }
}
