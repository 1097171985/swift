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

import Foundation
import SwiftFormatCore
import SwiftSyntax

/// Read-only computed properties must use implicit `get` blocks.
///
/// Lint: Read-only computed properties with explicit `get` blocks yield a lint error.
///
/// Format: Explicit `get` blocks are rendered implicit by removing the `get`.
///
/// - SeeAlso: https://google.github.io/swift#properties-2
public final class UseSingleLinePropertyGetter: SyntaxFormatRule {

  public override func visit(_ node: AccessorBlockSyntax) -> Syntax {
    guard
      let accessorList = node.accessorListOrStmtList as? AccessorListSyntax,
      let acc = accessorList.first,
      let body = acc.body,
      accessorList.count == 1,
      acc.accessorKind.tokenKind == .contextualKeyword("get"),
      acc.attributes == nil,
      acc.modifier == nil
    else { return node }

    diagnose(.removeExtraneousGetBlock, on: acc)

    return node.withAccessorListOrStmtList(body.statements)
  }
}

extension Diagnostic.Message {
  static let removeExtraneousGetBlock =
    Diagnostic.Message(.warning, "remove extraneous 'get {}' block")
}
