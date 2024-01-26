//
//  NetworkingError.swift
//  iOSRepositories
//
//  Created by Cuong Le on 1/3/21.
//  Copyright © All rights reserved.
//
// swiftlint:disable line_length
import Foundation

public protocol ResponseError: Codable {
    init(data: Data) throws
}
extension ResponseError {
    public init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

public extension Error {
    func customError<Type: ResponseError>(_ type: Type.Type) -> Type? {
        (self as? NetworkError)?.httpModel()
    }
}

public enum NetworkError: Error {
    case noData
    case invalidURL
    case encoding(String)
    case httpCode(HTTPCode, Data)
    case decoding(String)
    case unexpectedResponse
    case unauthorized
    case forbidded
}

extension NetworkError: LocalizedError, Equatable {
    public func httpModel<Type: ResponseError>() -> Type? {
        switch self {
        case .httpCode(_, let data):
            return try? Type(data: data)
        default:
            return nil
        }
    }
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "The request gave no data."
        case .invalidURL:
            return "Invalid URL"
        case let .httpCode(code, _):
            #if DEBUG
            return "Unexpected HTTP code: \(code)"
            #else
            return "The service is temporarily unavailable."
            #endif
        case let .decoding(error):
            return "Failed to map data to a Decodable object. \(error)"
        case let .encoding(error):
            return "Failed to encoding paramenters: \(error)"
        case .unexpectedResponse:
            return "Unexpected response from the server"
        case .unauthorized:
            return "Unathorized"
        case .forbidded:
            return "Forbidden (not authorized)"
        }
    }
    
    static func decodeErrorParse(error: Error) -> Error {
        if let error = error as? DecodingError {
            var errorToReport = error.localizedDescription
            switch error {
            case .dataCorrupted(let context):
                let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) - (\(details))"
            case .keyNotFound(let key, let context):
                let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) (key: \(key), \(details))"
            case .typeMismatch(let type, let context), .valueNotFound(let type, let context):
                let details = context.underlyingError?.localizedDescription ?? context.codingPath.map { $0.stringValue }.joined(separator: ".")
                errorToReport = "\(context.debugDescription) (type: \(type), \(details))"
            @unknown default:
                break
            }
            return NetworkError.decoding(errorToReport.localizedLowercase)
        } else {
            return error
        }
    }
}
