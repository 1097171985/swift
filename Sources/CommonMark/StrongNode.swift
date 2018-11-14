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

/// An inline element that represents strong (i.e., bolded) text.
public struct StrongNode: InlineContent {

  /// The children of the receiver.
  public let children: [InlineContent]

  public let sourceRange: Range<SourceLocation>?

  public var primitiveRepresentation: PrimitiveNode { return .strong(self) }

  /// Creates a new strong text node.
  ///
  /// - Parameters:
  ///   - children: Inline content nodes that are children of the new node.
  ///   - sourceRange: The source range from which the node was parsed, if known.
  public init(children: [InlineContent], sourceRange: Range<SourceLocation>? = nil) {
    self.children = children
    self.sourceRange = sourceRange
  }

  /// Returns a new node equivalent to the receiver, but whose children have been replaced with the
  /// given list of nodes.
  ///
  /// - Parameter children: The new list of children.
  /// - Returns: The new node.
  public func replacingChildren(_ children: [InlineContent]) -> StrongNode {
    return StrongNode(children: children, sourceRange: sourceRange)
  }

  /// Returns a new node equivalent to the receiver, but whose source range has been replaced with
  /// the given value.
  ///
  /// - Parameter sourceRange: The new source range.
  /// - Returns: The new node.
  public func replacingSourceRange(_ sourceRange: Range<SourceLocation>?) -> StrongNode {
    return StrongNode(children: children, sourceRange: sourceRange)
  }
}
