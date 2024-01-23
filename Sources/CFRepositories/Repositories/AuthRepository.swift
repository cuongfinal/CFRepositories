//
//  AuthWebRepository.swift
//  iOSRepositories
//
//  Created by Order Tiger on 28/5/21.
//  Copyright © All rights reserved.
//
// swiftlint:disable line_length
#if canImport(Combine) && os(iOS)
import Combine
import Foundation

public protocol AuthRepository: WebRepository {
//    func singUp(customer: Customer) async throws -> Customer
//    func forgotPassword(login: String) async throws -> SessionOutput
//
//    func signIn(login: String, password: String) async throws -> Customer
//    func temporaryToken() async throws
//    func refreshToken() async throws
}

struct AuthRepositoryImpl {
    let session: URLSession
    let baseURL: String
    let bgQueue = DispatchQueue(label: "bg_auth_queue") // , attributes: .concurrent
    var interceptor: RequestInterceptor?
    
//    @Injected var appState: AppStore<AppState>
//    @Injected var env: EnvironmentCompany
    
    init(configuration: ServiceConfiguration) {
        self.session = configuration.urlSession
        self.baseURL = configuration.environment.url
        self.interceptor = configuration.interceptor
    }
}

public enum AuthError: Error, LocalizedError {
    case tokenFindError
    case authNeeded
    public var errorDescription: String? {
        "Unable to find the token, please check the request header."
    }
}

// MARK: - Async impl
extension AuthRepositoryImpl {
//    func singUp(customer: Customer) async throws -> Customer {
//        let tmpCustomer = customer.with {
//            $0.companyId = self.env.companyId
//            $0.customerType = "MEMBER"
//            $0.language = Locale.current.languageCode
//        }.asDictionary
//        let result = try await tokenParser(endpoint: API.singUp(param: tmpCustomer), logger: .debug)
//        let customer: Customer = try await decodeJSON(data: result.data)
//        _ = try? KeychainStore.shared.store(item: customer, for: .customer, update: \.userData.customer)
//        return customer
//    }
//
//    func forgotPassword(login: String) async throws -> SessionOutput {
//        let param: Parameters = ["email": login, "companyId": env.companyId]
//        return try await execute(endpoint: API.forgotPassword(param: param), logLevel: .debug)
//    }
//
//    func signIn(login: String, password: String) async throws -> Customer {
//        let param: Parameters = ["userName": login, "password": password, "companyId": env.companyId]
//        let result: SessionOutput = try await tokenParser(endpoint: API.signIn(param: param), logger: .debug)
//        let customer: Customer = try await decodeJSON(data: result.data)
//        _ = try? KeychainStore.shared.store(item: customer, for: .customer, update: \.userData.customer)
//        return customer
//    }
//
//    func refreshToken() async throws {
//        print("refreshToken")
//        let customer = appState[\.userData.customer]
//        guard let login = customer?.email, let psw = customer?.password else { throw AuthError.authNeeded }
//        _ = try await signIn(login: login, password: psw)
//    }
//
//    func temporaryToken() async throws {
//        print("temporaryToken")
//        let ipAddress = Device.ipAddress ?? "95.87.65.249"
//        let param: Parameters = ["userName": ipAddress, "password": "app", "companyId": env.companyId]
//        _ = try await tokenParser(endpoint: API.temporaryToken(param: param), logger: .info)
//    }
//
//    func tokenParser(endpoint: ResourceType, logger: NetworkingLogLevel = .off) async throws -> SessionOutput {
//        let result: SessionOutput = try await execute(endpoint: endpoint, logLevel: logger)
//        guard let response = result.response as? HTTPURLResponse,
//              let token = response.value(forHTTPHeaderField: KeychainKey.token.rawValue) else {
//                  throw AuthError.tokenFindError
//              }
//        _ = try? KeychainStore.shared.store(item: token, for: .token)
//        return result
//    }
}

// MARK: - Protocol impl
extension AuthRepositoryImpl: AuthRepository {
//    func tokenParser(endpoint: ResourceType, logger: NetworkingLogLevel = .off) -> AnyPublisher<SessionOutput, Error> {
//        execute(endpoint: endpoint, logLevel: logger)
//            .tryMap { value in
//                guard let response = value.response as? HTTPURLResponse,
//                      let token = response.value(forHTTPHeaderField: KeychainKey.token.rawValue) else {
//                          throw AuthError.tokenFindError
//                      }
//
//                _ = try? KeychainStore.shared.store(item: token, for: .token)
//                return value
//            }.eraseToAnyPublisher()
//    }
}
// MARK: - Configuration
extension AuthRepositoryImpl {
    enum API: ResourceType {
        case signIn(param: Parameters),
             singUp(param: Parameters),
             forgotPassword(param: Parameters),
             temporaryToken(param: Parameters)
        
        var endPoint: Endpoint {
            switch self {
            case .signIn:
                return .post(path: "/customers/authenticate")
            case .singUp:
                return .post(path: "/customers")
            case .forgotPassword:
                return .post(path: "/customerpasswordresettokens")
            case .temporaryToken:
                return .post(path: "/customers/temporary_token")
            }
        }
        
        var task: HTTPTask {
            switch self {
            case .temporaryToken(let param),
                    .signIn(let param),
                    .forgotPassword(param: let param),
                    .singUp(let param):
                return .requestParameters(bodyParameters: param, encoding: .jsonEncoding)
            }
        }
        
        var headers: HTTPHeaders? {
            authHeader
        }
    }
}

#endif
