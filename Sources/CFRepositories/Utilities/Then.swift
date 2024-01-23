//
//  Then.swift
//  iOSRepositories
//
//  Created by Order Tiger on 5/6/21.
//  Copyright © All rights reserved.
//

import Foundation
import UIKit.UIGeometry

public protocol Then {}

extension Then where Self: Any {

  /// Makes it available to set properties with closures just after initializing and copying the value types.
  ///
  ///     let frame = CGRect().with {
  ///       $0.origin.x = 10
  ///       $0.size.width = 100
  ///     }
  @inlinable
  public func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
    var copy = self
    try block(&copy)
    return copy
  }

  /// Makes it available to execute something with closures.
  ///
  ///     UserDefaults.standard.do {
  ///       $0.set("devxoul", forKey: "username")
  ///       $0.set("devxoul@gmail.com", forKey: "email")
  ///       $0.synchronize()
  ///     }
  @inlinable
  public func `do`(_ block: (Self) throws -> Void) rethrows {
    try block(self)
  }

}

extension NSObject: Then {}
extension Array: Then {}
extension Dictionary: Then {}
extension Set: Then {}
extension CGRect: Then {}
