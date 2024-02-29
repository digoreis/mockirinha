//
//  Digest.swift
//
//
//  Created by Rodrigo Reis on 29/02/2024.
//

import Foundation
import CryptoKit

public extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}


extension Mockirinha {
    static func generateKey(function: StaticString,
                            line: Int,
                            file: StaticString) -> String {
        let key = "\(file)|\(line)|\(function)".data(using: .utf8)!
        
        let digest = SHA256.hash(data: key)
        
        return digest.hexStr
    }
}
