//
//  WebRepository.swift
//  iOSRepositories
//
//  Created by Cuong Le on 2/3/21.
//  Copyright © All rights reserved.
//

#if canImport(Combine) && os(iOS)
import Combine
import Foundation

public protocol WebRepository {
    var baseURL: String { get }
    var session: URLSession { get }
    var bgQueue: DispatchQueue { get }
    var interceptor: RequestInterceptor? { get }
}

extension WebRepository {
    var retryCount: Int { 1 }
}

extension WebRepository {
    func execute<Value>(endpoint: ResourceType,
                        httpCodes: HTTPCodes = .success,
                        isFullPath: Bool = false,
                        logLevel: NetworkingLogLevel = .off) -> AnyPublisher<Value, Error> where Value: Decodable {
        self.execute(endpoint: endpoint, httpCodes: httpCodes, isFullPath: isFullPath, logLevel: logLevel)
            .decodeJSON(httpCodes: httpCodes)
    }
    
    func execute(endpoint: ResourceType,
                 httpCodes: HTTPCodes = .success,
                 isFullPath: Bool = false,
                 logLevel: NetworkingLogLevel = .off) -> AnyPublisher<SessionOutput, Error> {
        do {
            var baseURL = baseURL
            var request = try endpoint.urlRequest(baseURL: baseURL)
            if isFullPath {
                request = try endpoint.urlRequest()
            }
            return session
                .dataTaskPublisher(for: request)
                .map {
                    self.logger.log(request: request, logLevel: logLevel)
                    self.logger.log(response: $0.response, data: $0.data, logLevel: logLevel)
                    return $0
                }.request(httpCodes: httpCodes)
        } catch {
            return Fail<URLSession.DataTaskPublisher.Output, Error>(error: error).eraseToAnyPublisher()
        }
    }
    
    func execute(endpoint: ResourceType,
                 httpCodes: HTTPCodes = .success,
                 isFullPath: Bool = false,
                 logLevel: NetworkingLogLevel = .off,
                 retryIteration: Int = 0) async throws -> SessionOutput {
        var request = try endpoint.urlRequest(baseURL: baseURL)
        if isFullPath {
            request = try endpoint.urlRequest()
        }
        let sessionResponse = try await session.data(from: request)
        
        self.logger.log(request: request, logLevel: logLevel)
        self.logger.log(response: sessionResponse.1, data: sessionResponse.0, logLevel: logLevel)
        
        guard let code = (sessionResponse.1 as? HTTPURLResponse)?.statusCode else {
            throw NetworkError.unexpectedResponse
        }
        
//        if code == 401 { throw NetworkError.unauthorized }
        
        if code == 403 || code == 401 { // temp solution
            if retryIteration <= retryCount {
                try await interceptor?.refreshToken()
                return try await execute(endpoint: endpoint, httpCodes: httpCodes,
                                         logLevel: logLevel, retryIteration: retryIteration + 1)
            } else {
                if code == 401 { throw NetworkError.unauthorized }
                if code == 403 { throw NetworkError.forbidded }
            }
        }
        
        guard httpCodes.contains(code) else {
            throw NetworkError.httpCode(code, sessionResponse.0)
        }
        
        return sessionResponse
    }
    
    func execute<Value>(endpoint: ResourceType,
                        httpCodes: HTTPCodes = .success,
                        isFullPath: Bool = false,
                        logLevel: NetworkingLogLevel = .off,
                        retryIteration: Int = 0) async throws -> Value where Value: Decodable {
        let response = try await self.execute(endpoint: endpoint, httpCodes: httpCodes,
                                              isFullPath: isFullPath,
                                              logLevel: logLevel, retryIteration: retryIteration)
        return try await decodeJSON(data: response.data)
    }
    
    func decodeJSON<Value>(data: Data) async throws -> Value where Value: Decodable {
        do {
            return try JSONDecoder().decode(Value.self, from: data)
        } catch {
            throw NetworkError.decodeErrorParse(error: error)
        }
    }
    
    var logger: NetworkingLogger {
        NetworkingLogger.shared
    }
}

public typealias SessionOutput = URLSession.DataTaskPublisher.Output

// MARK: - Helpers
extension Publisher where Output == SessionOutput {
    func request(httpCodes: HTTPCodes = .success) -> AnyPublisher<Output, Error> {
        tryMap {
            assert(!Thread.isMainThread)
            guard let code = ($0.1 as? HTTPURLResponse)?.statusCode else {
                throw NetworkError.unexpectedResponse
            }
            
            if code == 401 { throw NetworkError.unauthorized }
            if code == 403 { throw NetworkError.forbidded }
            
            guard httpCodes.contains(code) else {
                throw NetworkError.httpCode(code, $0.0)
            }
            return $0
        }.eraseToAnyPublisher()
    }
    
    func decodeJSON<Value>(httpCodes: HTTPCodes = .success) -> AnyPublisher<Value, Error> where Value: Decodable {
        self.decodeJSON(type: Value.self, httpCodes: httpCodes)
    }
    
    func decodeJSON<Value>(type: Value.Type,
                           httpCodes: HTTPCodes = .success) -> AnyPublisher<Value, Error> where Value: Decodable {
        self.request(httpCodes: httpCodes)
            .map { $0.data }
            .extractUnderlyingError()
            .decode(type: type, decoder: JSONDecoder())
            .mapError { NetworkError.decodeErrorParse(error: $0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
#endif
