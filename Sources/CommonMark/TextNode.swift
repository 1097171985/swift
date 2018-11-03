/// An inline element that represents plain text.
public struct TextNode: InlineContent {

  /// The literal text content of the node.
  public let literalContent: String

  public let sourceRange: Range<SourceLocation>?

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
