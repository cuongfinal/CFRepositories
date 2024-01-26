//
//  ResourceType.swift
//  iOSRepositories
//
//  Created by Cuong Le on 1/3/21.
//  Copyright © All rights reserved.
//

import Combine
import Foundation

protocol ResourceType {
    var endPoint: Endpoint { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}

extension ResourceType {
    var cachePolicy: URLRequest.CachePolicy {
        .useProtocolCachePolicy
    }

    func urlRequest(baseURL: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + endPoint.path), !baseURL.isEmpty else {
            throw NetworkError.invalidURL
        }
        return try buildRequest(to: url)
    }
    
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: endPoint.path), !endPoint.path.isEmpty else {
            throw NetworkError.invalidURL
        }
        return try buildRequest(to: url)
    }

    private func buildRequest(to route: URL) throws -> URLRequest {
        var request = URLRequest(url: route)
        request.httpMethod = endPoint.method.rawValue
        request.cachePolicy = cachePolicy

        if let headers = self.headers {
            addAdditionalHeaders(headers, request: &request)
        }

        do {
            switch task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case let .requestParameters(bodyParameters, bodyEncoding, urlParameters):

                try configureParameters(bodyParameters: bodyParameters, bodyEncoding: bodyEncoding,
                                        urlParameters: urlParameters, request: &request)

            case let .requestParametersAndHeaders(bodyParameters,
                                                  bodyEncoding,
                                                  urlParameters,
                                                  additionalHeaders):

                addAdditionalHeaders(additionalHeaders, request: &request)
                try configureParameters(bodyParameters: bodyParameters,
                                        bodyEncoding: bodyEncoding,
                                        urlParameters: urlParameters,
                                        request: &request)
            }
            return request
        } catch {
            throw error
        }
    }

    private func configureParameters(bodyParameters: Parameters?,
                                     bodyEncoding: ParameterEncoding,
                                     urlParameters: Parameters?,
                                     request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters,
                                    urlParameters: urlParameters)
        } catch {
            throw NetworkError.encoding(error.localizedDescription)
        }
    }

    private func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else {
            return
        }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
