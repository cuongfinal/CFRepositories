//
//  NetworkingLogger.swift
//  iOSRepositories
//
//  Created by Cuong Le on 31/5/21.
//  Copyright © All rights reserved.
//

import Foundation

public enum NetworkingLogLevel {
    case off
    case info
    case debug
}

class NetworkingLogger {
    static let shared = NetworkingLogger()
    
    func log(request: URLRequest, logLevel: NetworkingLogLevel = .off) {
        guard logLevel != .off else {
            return
        }
        print("<==========🚀🚀🚀============BEGIN==============🚀🚀🚀===========>")
        if let verb = request.httpMethod, let url = request.url {
            print("\(verb) '\(url.absoluteString)' 🔚")
            print(request.httpHeaderFieldsDescription)
            print(request.logBody())
        }
    }
    
    func log(response: URLResponse, data: Data, logLevel: NetworkingLogLevel = .off) {
        guard logLevel != .off else {
            return
        }
        print("<==========🛬🛬🛬=========RESPONSE=============🛬🛬🛬============>")
        if let response = response as? HTTPURLResponse {
            print(response.logStatusCodeAndURL)
//            print(logLevel == .debug ? response.httpHeaderFieldsDescription : response.logStatusCodeAndURL)
        }
        if logLevel == .debug {
            print("Data:    ", data.prettyJSONString ?? "Data empty")
        }
        print("<==========🎬🎬🎬=============END============🎬🎬🎬==============>")
    }
}

private extension URLRequest {
    var httpHeaderFieldsDescription: String {
        guard let headers = allHTTPHeaderFields, !headers.isEmpty else {
            return ""
        }
        
        var values: [String] = []
        values.append("Headers: [")
        for (key, value) in headers {
            values.append("  \(key) : \(value)")
        }
        values.append("]")
        return values.joined(separator: "\n")
    }
    
    func logBody() {
        if let body = self.httpBody,
           let str = String(data: body, encoding: .utf8) {
            print("  HttpBody : \(str)")
        }
    }
}

private extension HTTPURLResponse {
    var httpHeaderFieldsDescription: String {
        guard !allHeaderFields.isEmpty else {
            return ""
        }
        
        var values: [String] = []
        values.append("Headers: [")
        for (key, value) in allHeaderFields {
            values.append("  \(key) : \(value)")
        }
        values.append("]")
        return values.joined(separator: "\n")
    }
    
    var logStatusCodeAndURL: String {
        " 🔥🔥🔥 Status code: \(self.statusCode)"
    }
}
