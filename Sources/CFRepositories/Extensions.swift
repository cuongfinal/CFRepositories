//
//  Extensions.swift
//  iOSRepositories
//
//  Created by Order Tiger on 1/3/21.
//  Copyright © All rights reserved.
//

import Combine
import Foundation
import UIKit

var authHeader: HTTPHeaders? {
//    guard let token: String = try? KeychainStore.shared.find(for: .token) else {
//        return nil
//    }
    return ["Authorization": "Bearer " + "token"]
}

public extension String {
    func asDictionary() -> [String: Any] {
        guard let data = data(using: .utf8),
              let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? Parameters else { return [:] }
        return dic
    }

    var toURL: URL? { URL(string: self) }
    
    var isEmptyConvertToNil: Self? {
        isEmpty ? nil : self
    }
    var removeNewLines: Self {
        trimmingCharacters(in: .newlines)
    }
    
    var asBool: Bool {
        return (self as NSString).boolValue
    }
}

// MARK: - Main sync safe
extension DispatchQueue {
    /// Executes given work synchronously in main thread, safely
    /// - Parameter work: Work to be done
    class func mainSyncSafe(execute work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
}

// MARK: - Optional
extension Optional where Wrapped: Combine.Publisher {
    func orEmpty() -> AnyPublisher<Wrapped.Output, Wrapped.Failure> {
        self?.eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher()
    }
}

// MARK: - DictionaryDynamicLookup
@dynamicMemberLookup
protocol DictionaryDynamicLookup {
    associatedtype Key
    associatedtype Value
    subscript(key: Key) -> Value? { get }
}

extension DictionaryDynamicLookup where Key == String {
    subscript(dynamicMember member: String) -> Value? {
        return self[member]
    }
}

extension Dictionary: DictionaryDynamicLookup {}

// MARK: - CurrentValueSubject
public extension CurrentValueSubject {
    subscript<T>(keyPath: WritableKeyPath<Output, T>) -> T where T: Equatable {
        get { value[keyPath: keyPath] }
        set {
            var value = self.value
            value[keyPath: keyPath] = newValue
            self.value = value
            //            if value[keyPath: keyPath] != newValue {
            //                value[keyPath: keyPath] = newValue
            //                self.value = value
            //            }
        }
    }
    
    subscript<T>(keyPath: KeyPath<Output, T>) -> T where T: Equatable {
        get { value[keyPath: keyPath] }
    }
    
    func bulkUpdate(_ update: (inout Output) -> Void) {
        var value = self.value
        update(&value)
        self.value = value
    }
    
    func updates<Value>(for keyPath: KeyPath<Output, Value>) -> AnyPublisher<Value, Failure> where Value: Equatable {
        return map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}

extension NSError {
    convenience init(msg: String) {
        self.init(domain: msg, code: 1051, userInfo: [:])
    }
}

// extension Binding {
//    typealias ValueClosure = (Value) -> Void
//
//    func onSet(_ perform: @escaping ValueClosure) -> Self {
//        return .init(get: { () -> Value in
//            self.wrappedValue
//        }, set: { value in
//            self.wrappedValue = value
//            perform(value)
//        })
//    }
// }

public extension Sequence {
    func sum<T: AdditiveArithmetic>(for keyPath: KeyPath<Element, T>) -> T {
        // Inspired by: https://swiftbysundell.com/articles/reducers-in-swift/
        return reduce(.zero) { $0 + $1[keyPath: keyPath] }
    }
}

public extension UserDefaults {
    func setCodableObject<T: Codable>(_ data: T?, forKey defaultName: String) {
        let encoded = try? JSONEncoder().encode(data)
        set(encoded, forKey: defaultName)
    }
    
    func codableObject<T : Codable>(dataType: T.Type, key: String) -> T? {
        guard let userDefaultData = data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: userDefaultData)
    }
}

class Device {
    public static var ipAddress: String? {
        getAddress(for: .wifi) ?? getAddress(for: .cellular)
    }
    
    static fileprivate func getVersionCode() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let versionCode: String = String(validatingUTF8: NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)!.utf8String!)!
        
        return versionCode
    }
    
    static func getAddress(for network: Network) -> String? {
        var address: String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if name == network.rawValue {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    enum Network: String {
        case wifi = "en0"
        case cellular = "pdp_ip0"
    }
}

public extension Task where Failure == Error {
    static func delayed(
        byTimeInterval delayInterval: TimeInterval,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            let delay = UInt64(delayInterval * 1_000_000_000)
            try await Task<Never, Never>.sleep(nanoseconds: delay)
            return try await operation()
        }
    }
}

public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
