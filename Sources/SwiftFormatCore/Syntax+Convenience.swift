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

import SwiftSyntax

extension Syntax {
  /// Performs a depth-first in-order traversal of the node to find the first
  /// node in its hierarchy that is a Token.
  public var firstToken: TokenSyntax? {
    if let tok = self as? TokenSyntax { return tok }
    for child in children {
      if let tok = child.firstToken { return tok }
    }
    return nil
  }

  /// Performs a depth-first reverse-order traversal of the node to find the last
  /// node in its hierarchy that is a Token.
  public var lastToken: TokenSyntax? {
    if let tok = self as? TokenSyntax { return tok }
    for child in children.reversed() {
      if let tok = child.lastToken { return tok }
    }
    return nil
  }

  /// Walks up from the current node to find the nearest node that is an
  /// Expr, Stmt, or Decl.
  public var containingExprStmtOrDecl: Syntax? {
    var node: Syntax? = self
    while let parent = node?.parent {
      if parent is ExprSyntax ||
         parent is StmtSyntax ||
         parent is DeclSyntax {
        return parent
      }
      node = parent
    }
    return nil
  }

  /// Recursively walks through the tree to find the next token semantically
  /// after this node.
  public var nextToken: TokenSyntax? {
    var current: Syntax? = self

    // Walk up the parent chain, checking adjacent siblings after each node
    // until we find a node with a 'first token'.
    while let node = current {
      // If we've walked to the top, just stop.
      guard let parent = node.parent else { break }

      // If we're not the last child, search through each sibling until
      // we find a token.
      if node.indexInParent < parent.numberOfChildren {
        for idx in (node.indexInParent + 1)..<parent.numberOfChildren {
          let nextChild = parent.child(at: idx)

          // If there's a token, we're good.
          if let child = nextChild?.firstToken { return child }
        }
      }

      // If we've exhausted siblings, move up to the parent.
      current = parent
    }
    return nil
  }

  /// Recursively walks through the tree to find the token semantically
  /// before this node.
  public var previousToken: TokenSyntax? {
    var current: Syntax? = self

    // Walk up the parent chain, checking adjacent siblings after each node
    // until we find a node with a 'first token'.
    while let node = current {
      // If we've walked to the top, just stop.
      guard let parent = node.parent else { break }

      // If we're not the first child, search through each previous sibling until
      // we find a token.
      if node.indexInParent > 0 {
        for idx in (0..<node.indexInParent).reversed() {
          let nextChild = parent.child(at: idx)

          // If there's a token, we're good.
          if let child = nextChild?.lastToken { return child }
        }
      }

      // If we've exhausted siblings, move up to the parent.
      current = parent
    }
    return nil
  }

  /// Sequence of tokens that are part of this Syntax node.
  public var tokens: TokenSequence {
    return TokenSequence(self)
  }
}

/// Sequence of tokens that are part of the provided Syntax node.
public struct TokenSequence: Sequence {
  public struct Iterator: IteratorProtocol {
    var nextToken: TokenSyntax?
    let endPosition: AbsolutePosition

    init(_ token: TokenSyntax?, endPosition: AbsolutePosition) {
      self.nextToken = token
      self.endPosition = endPosition
    }

    public mutating func next() -> TokenSyntax? {
      guard let token = self.nextToken else { return nil }
      self.nextToken = token.nextToken
      // Make sure we stop once we reach the end of the containing node.
      if let nextTok = self.nextToken, nextTok.position >= self.endPosition {
        self.nextToken = nil
      }
      return token
    }
  }

  let node: Syntax

  public init(_ node: Syntax) {
    self.node = node
  }

  public func makeIterator() -> Iterator {
    return Iterator(node.firstToken, endPosition: node.endPosition)
  }
}

extension AbsolutePosition: Comparable {
  public static func <(lhs: AbsolutePosition, rhs: AbsolutePosition) -> Bool {
    return lhs.utf8Offset < rhs.utf8Offset
  }
  public static func ==(lhs: AbsolutePosition, rhs: AbsolutePosition) -> Bool {
    return lhs.utf8Offset == rhs.utf8Offset
  }
}
