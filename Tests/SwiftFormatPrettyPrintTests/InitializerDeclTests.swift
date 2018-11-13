public class InitializerDeclTests: PrettyPrintTestCase {
  public func testBasicInitializerDeclarations() {
    let input =
      """
      struct Struct {
        init(var1: Int, var2: Double) {
            print("Hello World")
            let a = 23
        }
        init(reallyLongLabelVar1: Int, var2: Double, var3: Bool) {
            print("Hello World")
            let a = 23
        }
        init() {
            let a = 23
        }
        init() { let a = "AAAA BBBB CCCC DDDD EEEE FFFF" }
      }
      """

    let expected =
      """
      struct Struct {
        init(var1: Int, var2: Double) {
          print("Hello World")
          let a = 23
        }
        init(
          reallyLongLabelVar1: Int,
          var2: Double,
          var3: Bool
        ) {
          print("Hello World")
          let a = 23
        }
        init() { let a = 23 }
        init() {
          let a = "AAAA BBBB CCCC DDDD EEEE FFFF"
        }
      }

      """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 50)
  }

  public func testInitializerOptionality() {
    let input =
    """
      struct Struct {
        init? (var1: Int, var2: Double) {
            print("Hello World")
            let a = 23
        }
        init! (reallyLongLabelVar1: Int, var2: Double, var3: Bool) {
            print("Hello World")
            let a = 23
        }
        init?() {
            let a = 23
        }
        init!() { let a = "AAAA BBBB CCCC DDDD EEEE FFFF" }
      }
      """
    
    let expected =
    """
      struct Struct {
        init?(var1: Int, var2: Double) {
          print("Hello World")
          let a = 23
        }
        init!(
          reallyLongLabelVar1: Int,
          var2: Double,
          var3: Bool
        ) {
          print("Hello World")
          let a = 23
        }
        init?() { let a = 23 }
        init!() {
          let a = "AAAA BBBB CCCC DDDD EEEE FFFF"
        }
      }

      """
    
    assertPrettyPrintEqual(input: input, expected: expected, linelength: 50)
  }

  public func testInitializerDeclThrows() {
    let input =
      """
      struct Struct {
        init(var1: Int, var2: Double) throws {
          print("Hello World")
        }
        init(reallyLongLabelVar1: Int, var2: Double, var3: Bool) throws {
          print("Hello World")
        }
      }
      """

    let expected =
      """
      struct Struct {
        init(var1: Int, var2: Double) throws {
          print("Hello World")
        }
        init(
          reallyLongLabelVar1: Int,
          var2: Double,
          var3: Bool
        ) throws { print("Hello World") }
      }

      """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 50)
  }

  public func testInitializerGenericParameters() {
    let input =
    """
    struct Struct {
      init<S, T>(var1: S, var2: T) {
        let a = 123
        print("Hello World")
      }

      init<ReallyLongTypeName: Conform, TypeName>(var1: ReallyLongTypeName, var2: TypeName) {
        let a = 123
        let b = 456
      }
    }
    """

    let expected =
    """
    struct Struct {
      init<S, T>(var1: S, var2: T) {
        let a = 123
        print("Hello World")
      }

      init<
        ReallyLongTypeName: Conform,
        TypeName
      >(
        var1: ReallyLongTypeName,
        var2: TypeName
      ) {
        let a = 123
        let b = 456
      }
    }

    """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 40)
  }

  public func testInitializerWhereClause() {
    let input =
    """
    struct Struct {
      public init<Elements: Collection, Element>(
        element: Element,
        in collection: Elements
      ) where Elements.Element == Element {
        let a = 123
        let b = "abc"
      }

      public init<Elements: Collection, Element>(
        element: Element,
        in collection: Elements
      ) where Elements.Element == Element, Element: Equatable {
        let a = 123
        let b = "abc"
      }
    }
    """

    let expected =
    """
    struct Struct {
      public init<Elements: Collection, Element>(
        element: Element,
        in collection: Elements
      ) where Elements.Element == Element {
        let a = 123
        let b = "abc"
      }

      public init<Elements: Collection, Element>(
        element: Element,
        in collection: Elements
      )
      where
        Elements.Element == Element,
        Element: Equatable
      {
        let a = 123
        let b = "abc"
      }
    }

    """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 50)
  }

  public func testInitializerAttributes() {
    let input =
      """
      struct Struct {
        @objc public init() {
          let a = 123
          let b = "abc"
        }
        @objc @inlinable public init() {
          let a = 123
          let b = "abc"
        }
        @objc @available(swift 4.0) public init() {
          let a = 123
          let b = "abc"
        }
      }
      """

    let expected =
      """
      struct Struct {
        @objc public init() {
          let a = 123
          let b = "abc"
        }
        @objc
        @inlinable
        public init() {
          let a = 123
          let b = "abc"
        }
        @objc
        @available(swift 4.0)
        public init() {
          let a = 123
          let b = "abc"
        }
      }

      """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 30)
  }


  public func testInitializerFullWrap() {
    let input =
    """
    struct Struct {
      @objc @inlinable
      public init<Elements: Collection, Element>(element: Element, in collection: Elements) where Elements.Element == Element, Element: Equatable {
        let a = 123
        let b = "abc"
      }
    }
    """

    let expected =
    """
    struct Struct {
      @objc
      @inlinable
      public init<
        Elements: Collection,
        Element
      >(
        element: Element,
        in collection: Elements
      )
      where
        Elements.Element == Element,
        Element: Equatable
      {
        let a = 123
        let b = "abc"
      }
    }

    """

    assertPrettyPrintEqual(input: input, expected: expected, linelength: 40)
  }
}
