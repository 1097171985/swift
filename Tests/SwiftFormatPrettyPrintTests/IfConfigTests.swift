public class IfConfigTests: PrettyPrintTestCase {
  public func testBasicIfConfig() {
    let input =
      """
      #if someCondition
        let a = 123
        let b = "abc"
      #endif

      #if someCondition
        let a = 123
        let b = "abc"
      #else
        let c = 456
        let d = "def"
      #endif

      #if swift(>=4.0)
        print("Stuff")
      #endif
      #if swift(>=4.0)
        print("Stuff")
      #elseif compiler(>=3.0)
        print("More Stuff")
        print("Another Line")
      #endif
      """

    let expected =
      """
      #if someCondition
        let a = 123
        let b = "abc"
      #endif

      #if someCondition
        let a = 123
        let b = "abc"
      #else
        let c = 456
        let d = "def"
      #endif

      #if swift(>=4.0)
        print("Stuff")
      #endif
      #if swift(>=4.0)
        print("Stuff")
      #elseif compiler(>=3.0)
        print("More Stuff")
        print("Another Line")
      #endif

      """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 45)
  }
}
