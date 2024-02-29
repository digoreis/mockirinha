//
//  Response.swift
//
//
//  Created by Rodrigo Reis on 29/02/2024.
//

import Foundation

extension Mockirinha {
    public enum Response {
        case payload(ResponseCode, Data)
        case empty(ResponseCode)
        case error(Error)
    }
}
