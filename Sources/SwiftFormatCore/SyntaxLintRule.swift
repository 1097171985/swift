//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Formatter open source project.
//
// Copyright (c) 2018 Apple Inc. and the Swift Formatter project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Formatter project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftSyntax

/// A rule that lints a given file.
open class SyntaxLintRule: SyntaxVisitor, Rule {
  /// The context in which the rule is executed.
  public let context: Context

  /// Creates a new SyntaxLintRule in the given context.
  public required init(context: Context) {
    self.context = context
  }
}

extension Rule {
  /// Emits the provided diagnostic to the diagnostic engine.
  ///
  /// - Parameters:
  ///   - message: The diagnostic message to emit.
  ///   - location: The source location which the diagnostic should be attached.
  ///   - actions: A set of actions to add notes, highlights, and fix-its to diagnostics.
  public func diagnose(
    _ message: Diagnostic.Message,
    on node: Syntax?,
    actions: ((inout Diagnostic.Builder) -> Void)? = nil
  ) {
    // TODO: node?.startLocation should be returning the position ignoring leading trivia. It isn't
    // working properly, so we are using this workaround until it is fixed.
    let loc = node.map {
      SourceLocation(
        file: context.fileURL.path,
        position: $0.positionAfterSkippingLeadingTrivia
      )
    }
    context.diagnosticEngine?.diagnose(
      message.withRule(self),
      location: loc,
      actions: actions
    )
  }
}
