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

import Basic
import Foundation
import SwiftFormat
import SwiftFormatConfiguration
import SwiftFormatCore
import SwiftSyntax

/// Runs the linting pipeline over the provided source file.
///
/// If there were any lint diagnostics emitted, this function returns a non-zero exit code.
/// - Parameter configuration: The `Configuration` that contains user-specific settings.
/// - Parameter path: The absolute path to the source file to be linted.
/// - Returns: Zero if there were no lint errors, otherwise a non-zero number.
func lintMain(configuration: Configuration, path: String) -> Int {
  let url = URL(fileURLWithPath: path)
  let diagnosticEngine = makeDiagnosticEngine()
  let linter = SwiftLinter(configuration: configuration, diagnosticEngine: diagnosticEngine)

  do {
    try linter.lint(contentsOf: url)
  } catch {
    fatalError("\(error)")
  }
  return diagnosticEngine.diagnostics.isEmpty ? 0 : 1
}

/// Runs the formatting pipeline over the provided source file.
///
/// - Parameters:
///   - configuration: The `Configuration` that contains user-specific settings.
///   - path: The absolute path to the source file to be formatted.
///   - debugOptions: The set containing any debug options that were supplied on the command line.
/// - Returns: Zero if there were no lint errors, otherwise a non-zero number.
func formatMain(
  configuration: Configuration, path: String, debugOptions: DebugOptions
) -> Int {
  let url = URL(fileURLWithPath: path)
  let formatter = SwiftFormatter(configuration: configuration, diagnosticEngine: nil)
  formatter.debugOptions = debugOptions

  do {
    try formatter.format(contentsOf: url, to: &stdoutStream)
  } catch {
    fatalError("\(error)")
  }
  return 0
}

/// Makes and returns a new configured diagnostic engine.
private func makeDiagnosticEngine() -> DiagnosticEngine {
  let engine = DiagnosticEngine()
  let consumer = PrintingDiagnosticConsumer()
  engine.addConsumer(consumer)
  return engine
}
