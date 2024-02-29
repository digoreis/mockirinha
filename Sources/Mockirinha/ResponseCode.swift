//
//  ResponseCode.swift
//  
//
//  Created by Rodrigo Reis on 29/02/2024.
//

import Foundation

extension Mockirinha {
    public enum ResponseCode: Int {
        case ok = 200
        case create = 201
        case accepted = 202
        case noContent = 204
        case badRequest = 400
        case unathorized = 401
        case forbidden = 403
        case notFound = 404
        case methodNotAllowed = 405
        case requestTimeout = 408
        case tooManyRequest = 429
        case internalServerError = 500
        case notImplemented = 501
        case badGateway = 502
        case serviceUnavaible = 503
        case gatewayTimeout = 504
    }
}
