//
//  CancelBag.swift
//  iOSRepositories
//
//  Created by Order Tiger on 10/5/21.
//  Copyright © All rights reserved.
//
#if canImport(Combine) && os(iOS)
import Combine

public final class CancelBag {
    fileprivate(set) var subscriptions = Set<AnyCancellable>()
    
    public init() { }
    
   public func cancel() {
        subscriptions.removeAll()
    }
    
   public func collect(@Builder _ cancellables: () -> [AnyCancellable]) {
        subscriptions.formUnion(cancellables())
    }
}

@resultBuilder public struct Builder {
   public static func buildBlock(_ cancellables: AnyCancellable...) -> [AnyCancellable] {
        return cancellables
    }
}

public extension AnyCancellable {
    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
#endif
