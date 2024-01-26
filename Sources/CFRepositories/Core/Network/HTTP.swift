//
//  HTTP.swift
//  iOSRepositories
//
//  Created by Cuong Le on 2/3/21.
//  Copyright © All rights reserved.
//

import Foundation

public typealias HTTPCode = Int
typealias HTTPCodes = Range<HTTPCode>

extension HTTPCodes {
    static let success = 200 ..< 300
}

typealias HTTPHeaders = [String: String]

enum HTTPTask {
    case request

    case requestParameters(bodyParameters: Parameters? = nil,
                           encoding: ParameterEncoding,
                           urlParameters: Parameters? = nil)

    case requestParametersAndHeaders(bodyParameters: Parameters? = nil,
                                     bodyEncoding: ParameterEncoding,
                                     urlParameters: Parameters? = nil,
                                     additionHeaders: HTTPHeaders? = nil)

    // case download, upload...etc
}

enum Endpoint {
    case get(path: String)
    case post(path: String)
    case put(path: String)
    case delete(path: String)
    case patch(path: String)

    internal var path: String {
        switch self {
        case let .get(path),
             let .post(path),
             let .put(path),
             let .delete(path),
             let .patch(path):
            return path
        }
    }
}

extension Endpoint {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    var method: HTTPMethod {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        case .put:
            return .put
        case .delete:
            return .delete
        case .patch:
            return .patch
        }
    }
}
