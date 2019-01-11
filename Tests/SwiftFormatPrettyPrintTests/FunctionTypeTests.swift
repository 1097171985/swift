public class FunctionTypeTests: PrettyPrintTestCase {
  public func testFunctionType() {
    let input =
      """
      func f(g: (_ somevalue: Int) -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (currentLevel: Int) -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (currentLevel: inout Int) -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (variable1: Int, variable2: Double, variable3: Bool) -> Double) {
        let a = 123
        let b = "abc"
      }
      func f(g: (variable1: Int, variable2: Double, variable3: Bool, variable4: String) -> Double) {
        let a = 123
        let b = "abc"
      }
      """

    let expected =
      """
      func f(g: (_ somevalue: Int) -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (currentLevel: Int) -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (currentLevel: inout Int) -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(
        g: (variable1: Int, variable2: Double, variable3: Bool) ->
        Double
      ) {
        let a = 123
        let b = "abc"
      }
      func f(
        g: (
          variable1: Int,
          variable2: Double,
          variable3: Bool,
          variable4: String
        ) -> Double
      ) {
        let a = 123
        let b = "abc"
      }

      """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 60)
  }

  public func testFunctionTypeThrows() {
    let input =
      """
      func f(g: (_ somevalue: Int) throws -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (currentLevel: Int) throws -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (currentLevel: inout Int) throws -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (variable1: Int, variable2: Double, variable3: Bool) throws -> Double) {
        let a = 123
        let b = "abc"
      }
      func f(g: (variable1: Int, variable2: Double, variable3: Bool, variable4: String) throws -> Double) {
        let a = 123
        let b = "abc"
      }
      """
    
    let expected =
      """
      func f(g: (_ somevalue: Int) throws -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (currentLevel: Int) throws -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(g: (currentLevel: inout Int) throws -> String?) {
        let a = 123
        let b = "abc"
      }
      func f(
        g: (variable1: Int, variable2: Double, variable3: Bool) throws ->
        Double
      ) {
        let a = 123
        let b = "abc"
      }
      func f(
        g: (
          variable1: Int,
          variable2: Double,
          variable3: Bool,
          variable4: String
        ) throws -> Double
      ) {
        let a = 123
        let b = "abc"
      }

      """
    
    assertPrettyPrintEqual(input: input, expected: expected, linelength: 67)
  }
}
