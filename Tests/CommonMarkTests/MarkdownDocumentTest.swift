import CommonMark
import XCTest

final class MarkdownDocumentTest: XCTestCase {

  func testInitByParsing_blockQuote() {
    let document = MarkdownDocument(byParsing: "> Foo")

    let blockQuote = document.children[0] as! BlockQuoteNode
    let paragraph = blockQuote.children[0] as! ParagraphNode
    let text = paragraph.children[0] as! TextNode
    XCTAssertEqual(text.literalContent, "Foo")
  }

  func testInitByParsing_codeBlock() {
    let document = MarkdownDocument(byParsing: """
      ```swift
      func foo() {}
      ```
      """)

    let codeBlock = document.children[0] as! CodeBlockNode
    XCTAssertEqual(codeBlock.fenceText, "swift")
    XCTAssertEqual(codeBlock.literalContent, "func foo() {}\n")
  }

  func testInitByParsing_emphasis() {
    let document = MarkdownDocument(byParsing: "_foo_")

    let paragraph = document.children[0] as! ParagraphNode
    let emphasis = paragraph.children[0] as! EmphasisNode
    let text = emphasis.children[0] as! TextNode
    XCTAssertEqual(text.literalContent, "foo")
  }

  func testInitByParsing_HTMLBlock() {
    let document = MarkdownDocument(byParsing: """
      <section>
      foo
      </section>

      """)

    let html = document.children[0] as! HTMLBlockNode
    XCTAssertEqual(html.literalContent, """
      <section>
      foo
      </section>

      """)
  }

  func testInitByParsing_header() {
    let document = MarkdownDocument(byParsing: "# Foo")

    let header = document.children[0] as! HeaderNode
    XCTAssertEqual(header.level, .h1)
    let text = header.children[0] as! TextNode
    XCTAssertEqual(text.literalContent, "Foo")
  }

  func testInitByParsing_horizontalRule() {
    let document = MarkdownDocument(byParsing: """
      foo

      ---

      bar
      """)

    let rule = document.children[1] as? HorizontalRuleNode
    XCTAssertNotNil(rule)
  }

  func testInitByParsing_image() {
    let document = MarkdownDocument(byParsing: "![foo](http://bar \"title\")")

    let paragraph = document.children[0] as! ParagraphNode
    let image = paragraph.children[0] as! ImageNode
    XCTAssertEqual(image.title, "title")
    XCTAssertEqual(image.url, URL(string: "http://bar"))
  }

  func testInitByParsing_inlineHTML() {
    let document = MarkdownDocument(byParsing: "foo <b>foo</b> bar")

    let paragraph = document.children[0] as! ParagraphNode
    let startTag = paragraph.children[1] as! InlineHTMLNode
    XCTAssertEqual(startTag.literalContent, "<b>")
    let content = paragraph.children[2] as! TextNode
    XCTAssertEqual(content.literalContent, "foo")
    let endTag = paragraph.children[3] as! InlineHTMLNode
    XCTAssertEqual(endTag.literalContent, "</b>")
  }

  func testInitByParsing_lineBreak() {
    let document = MarkdownDocument(byParsing: """
      foo\\
      bar
      """)

    let paragraph = document.children[0] as! ParagraphNode
    let lineBreak = paragraph.children[1] as? LineBreakNode
    XCTAssertNotNil(lineBreak)
  }

  func testInitByParsing_link() {
    let document = MarkdownDocument(byParsing: "[foo](http://bar \"title\")")

    let paragraph = document.children[0] as! ParagraphNode
    let link = paragraph.children[0] as! LinkNode
    XCTAssertEqual(link.title, "title")
    XCTAssertEqual(link.url, URL(string: "http://bar"))
  }

  func testInitByParsing_listBulleted() {
    let document = MarkdownDocument(byParsing: """
      * Foo

      * Bar
      """)

    let list = document.children[0] as! ListNode
    XCTAssertFalse(list.isTight)
    XCTAssertEqual(list.listType, .bulleted)

    let item = list.items[0]
    let paragraph = item.children[0] as! ParagraphNode
    let text = paragraph.children[0] as! TextNode
    XCTAssertEqual(text.literalContent, "Foo")
  }

  func testInitByParsing_listOrdered() {
    let document = MarkdownDocument(byParsing: """
      3. Foo
      4. Bar
      """)

    let list = document.children[0] as! ListNode
    XCTAssertTrue(list.isTight)
    XCTAssertEqual(list.listType, .ordered(delimiter: .period, startingNumber: 3))

    let item = list.items[0]
    let paragraph = item.children[0] as! ParagraphNode
    let text = paragraph.children[0] as! TextNode
    XCTAssertEqual(text.literalContent, "Foo")
  }

  func testInitByParsing_softBreak() {
    let document = MarkdownDocument(byParsing: """
      foo
      bar
      """)

    let paragraph = document.children[0] as! ParagraphNode
    let softBreak = paragraph.children[1] as? SoftBreakNode
    XCTAssertNotNil(softBreak)
  }

  func testInitByParsing_strong() {
    let document = MarkdownDocument(byParsing: "**foo**")

    let paragraph = document.children[0] as! ParagraphNode
    let strong = paragraph.children[0] as! StrongNode
    let text = strong.children[0] as! TextNode
    XCTAssertEqual(text.literalContent, "foo")
  }

  func testInitByParsing_text() {
    let document = MarkdownDocument(byParsing: "basic")

    let paragraph = document.children[0] as! ParagraphNode
    let text = paragraph.children[0] as! TextNode
    XCTAssertEqual(text.literalContent, "basic")
  }
}

#if !os(macOS)
extension MarkdownDocumentTest {

  static let allTests = [
    ("testInitByParsing_blockQuote", testInitByParsing_blockQuote),
    ("testInitByParsing_codeBlock", testInitByParsing_codeBlock),
    ("testInitByParsing_emphasis", testInitByParsing_emphasis),
    ("testInitByParsing_HTMLBlock", testInitByParsing_HTMLBlock),
    ("testInitByParsing_header", testInitByParsing_header),
    ("testInitByParsing_horizontalRule", testInitByParsing_horizontalRule),
    ("testInitByParsing_image", testInitByParsing_image),
    ("testInitByParsing_inlineHTML", testInitByParsing_inlineHTML),
    ("testInitByParsing_lineBreak", testInitByParsing_lineBreak),
    ("testInitByParsing_link", testInitByParsing_link),
    ("testInitByParsing_listBulleted", testInitByParsing_listBulleted),
    ("testInitByParsing_listOrdered", testInitByParsing_listOrdered),
    ("testInitByParsing_softBreak", testInitByParsing_softBreak),
    ("testInitByParsing_strong", testInitByParsing_strong),
    ("testInitByParsing_text", testInitByParsing_text),
  ]
}
#endif
