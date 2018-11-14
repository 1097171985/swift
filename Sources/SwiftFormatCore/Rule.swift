//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2018 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

/// A Rule is a linting or formatting pass that executes in a given context.
public protocol Rule {
  /// The context in which the rule is executed.
  var context: Context { get }

  /// The human-readable name of the rule. This defaults to the class name.
  var ruleName: String { get }

  /// Creates a new Rule in a given context.
  init(context: Context)
}

private var nameCache = [ObjectIdentifier: String]()

extension Rule {
  /// By default, the `ruleName` is just the name of the implementing rule class.
  public var ruleName: String {
    let myType = type(of: self)
    // TODO(abl): Test and potentially replace with static initialization.
    return nameCache[
      ObjectIdentifier(myType),
      default: String("\(myType)".split(separator: ".").last!)
    ]
  }
}
