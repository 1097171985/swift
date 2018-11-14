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

/// An inline element that represents plain text.
public struct TextNode: InlineContent {

  /// The literal text content of the node.
  public let literalContent: String

  public let sourceRange: Range<SourceLocation>?

  public var primitiveRepresentation: PrimitiveNode { return .text(self) }

  /// Creates a new text node.
  ///
  /// - Parameters:
  ///   - literalContent: The literal text content of the node.
  ///   - sourceRange: The source range from which the node was parsed, if known.
  public init(literalContent: String, sourceRange: Range<SourceLocation>? = nil) {
    self.literalContent = literalContent
    self.sourceRange = sourceRange
  }

  /// Returns a new node equivalent to the receiver, but whose literal content has been replaced
  /// with the given string.
  ///
  /// - Parameter literalContent: The new literal content.
  /// - Returns: The new node.
  public func replacingLiteralContent(_ literalContent: String) -> TextNode {
    return TextNode(literalContent: literalContent, sourceRange: sourceRange)
  }

  /// Returns a new node equivalent to the receiver, but whose source range has been replaced with
  /// the given value.
  ///
  /// - Parameter sourceRange: The new source range.
  /// - Returns: The new node.
  public func replacingSourceRange(_ sourceRange: Range<SourceLocation>?) -> TextNode {
    return TextNode(literalContent: literalContent, sourceRange: sourceRange)
  }
}
