//
//  iOSRepositories.swift
//  iOSRepositories
//
//  Created by Order Tiger on 30 Mar 2021.
//  Copyright © All rights reserved.
//

// Include Foundation
@_exported import Foundation

public enum NetworkEnvironment {
    case testing(url: String)
    case production(url: String)
    case dev(url: String)
    
    var url: String {
        switch self {
        case .testing(let url), .production(let url), .dev(let url):
            return url
        }
    }
}

public protocol RequestInterceptor {
    func refreshToken() async throws
}

public protocol ServiceConfiguration {
    var environment: NetworkEnvironment { get }
    var urlSession: URLSession { get }
    var interceptor: RequestInterceptor { get }
}

public protocol AppEnvironment {
    var serviceConfig: ServiceConfiguration { get }
}

/// RepositoryModule module definition
public final class IOSRepositories<T: AppEnvironment> {
    // MARK: - Fields
    var env: T
    // MARK: - Initializers
    
    /// Initializes a new instance
    public init(env: T) {
        // Initialize instance here as needed
        self.env = env
    }
    
    // MARK: - Routing
    
    /// Registers DI
    public func registerDI() {
        print("IOSRepositories registerDI")
//        Resolver.register { self.env.appState }.scope(.shared)
//        Resolver.register { self.env.companyConfig }.scope(.shared)
//        Resolver.register { self.env.systemEventsHandler }.scope(.shared)
        
//        Resolver.register {
//            SystemWebRepositoryImpl(configuration: self.env.serviceConfig)
//        }.implements(SystemWebRepository.self)
    }
}
