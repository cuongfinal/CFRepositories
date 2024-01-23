//
//  Codable+Extension.swift
//  iOSRepositories
//
//  Created by Order Tiger on 4/8/21.
//  Copyright © All rights reserved.
//

import Foundation
extension Data {
    var prettyJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
              let prettyPrintedData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        else { return nil }
        
        return NSString(data: prettyPrintedData, encoding: String.Encoding.utf8.rawValue)
    }
}

public extension Encodable {
    var jsonData: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try? encoder.encode(self)
    }
    
    var jsonString: String {
        if let data = self.jsonData, let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "can not convert to json string"
    }
    var asDictionary: [String: Any] {
        jsonString.asDictionary()
    }
}

public protocol CodableValueProvider {
    associatedtype Value: Equatable & Codable

    static var `default`: Value { get }
}

public enum False: CodableValueProvider {
    public static let `default` = false
}
public typealias DefaultFalse = CCodable<False>

public enum EmptyValue<A>: CodableValueProvider where A: Codable, A: Equatable, A: RangeReplaceableCollection {
    public static var `default`: A { A() }
}
public typealias DefaultEmpty<A> = CCodable<EmptyValue<A>> where A: Codable, A: Equatable, A: RangeReplaceableCollection

public enum Exclude: CodableValueProvider {
    public static var `default` = 0
}
public typealias ExcludeValue = CCodable<Exclude>

/// Custom codable
@propertyWrapper
public struct CCodable<Provider: CodableValueProvider>: Codable {
    public var wrappedValue: Provider.Value
    
    public init() {
        wrappedValue = Provider.default
    }
    
    public init(wrappedValue: Provider.Value, exclude: Bool) {
        self.wrappedValue = wrappedValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            wrappedValue = Provider.default
        } else {
            wrappedValue = try container.decode(Provider.Value.self)
        }
    }
}

extension CCodable: Equatable where Provider.Value: Equatable {}
extension CCodable: Hashable where Provider.Value: Hashable {}

public extension KeyedDecodingContainer {
    func decode<P>(_: CCodable<P>.Type, forKey key: Key) throws -> CCodable<P> {
        if let value = try decodeIfPresent(CCodable<P>.self, forKey: key) {
            return value
        } else {
            return CCodable()
        }
    }
}

public extension KeyedEncodingContainer {
    mutating func encode<P>(_ value: CCodable<P>, forKey key: Key) throws {
//        guard value.wrappedValue != P.default else { return }
//        try encode(value.wrappedValue, forKey: key)
    }
}
