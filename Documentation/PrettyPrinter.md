# SwiftFormat Pretty Printer

## Introduction

The algorithm used in the SwiftFormat pretty printer is based on the "simple"
version of the algorithm described by Derek Oppen in his paper [*Pretty
Printing*](http://i.stanford.edu/pub/cstr/reports/cs/tr/79/770/CS-TR-79-770.pdf)
(1979). It employs two functions: *scan* and *print*. The *scan* function
accepts a stream of tokens and calculates the lengths of these tokens. It then
passes the tokens and their computed lengths to *print*, which handles the
actual printing of the tokens, automatically inserting line breaks and indents
to obey a given maximum line length. We describe in detail how these functions
have been implemented in SwiftFormat.

## Tokens

### Token Groups

It is often necessary to group a series of tokens together into logical groups
that we want to avoid splitting with line break if possible. The algorithm tries
to break as few groups as possible when printing. Groups begin with *open*
tokens and end with *close* tokens. These tokens must always be paired.

### Token Types

The different types of tokens are represented as a Token `enum` within the code.
The available cases are: `syntax`, `break`, `open`, `close`, `newlines`,
`comment`, `reset`, and `verbatim`. The behavior of each of them is described
below with pseudocode examples.

See: [`Token.swift`](../Sources/SwiftFormatPrettyPrint/Token.swift)

#### Syntax

The *syntax* tokens contain the segments of text that need to be printed (e.g.
`}`, `func`, `23`, `while`, etc.). The length of a token is the number of
columns needed to print it. For example, `func` would have a length of 4.

#### Break

The *break* tokens indicate where line breaks are allowed to occur. These
frequently occur as the whitespace in between syntax tokens. The breaks contain
two associated values that can be specified when creating the break token:
*size* and *offset*. The size indicates how many columns of whitespace should
be printed when the token is encountered. If a line break should occur at the
break token, the offset indicates how many spaces should be used for indentation
of the next token. The length of a break is its size plus the length of the
token that immediately come after it. If a break immediately precedes a group,
its length will be its size plus the size of the group.

```
# break(size, offset)
Tokens = ["one", break(1, 2), "two", break(1, 2), "three"]
Lengths = [3, 4, 3, 6, 5]

# Maximum line length of 10
Output =
"""
one two
  three
"""
```

#### Open

An *open* token indicates the start of a group.

```
# break(size=1, offset=0)
Token = ["one", break, open, "two", break, "three", break, open, "four", break, "five", close, close]

# Maximum line length of 20
Output =
"""
one
two three four five
"""

# Maximum line length of 10
Output =
"""
one
two three
four five
"""
```

Open tokens have a *break style* and an *offset*. The break style is either
*consistent* or *inconsistent*. If a group is too large to fit on the remaining
space on a line, and it is labeled as *consistent*, then the break tokens it
contains will all produce line breaks. (In the case of nested groups, the break
style affects a group's immediate children.) The default behavior is
*inconsistent*, in which case the break tokens only produce line breaks when
their lengths exceed the remaining space on the line.

```
# open(consistent/inconsistent), break(size, offset)
Tokens = ["one", break(1, 0), open(C), "two", break(1, 0), "three", close]

# Maximum line length of 10 (consistent breaking)
Output =
"""
one
two
three
"""

# With inconsistent breaking
Tokens = ["one", break(1, 0), open(I), "two", break(1, 0), "three", close]
Output =
"""
one
two three
"""
```

The open token's offset applies an offset to the breaks contained within the
group. A break token's offset value is added to the offset of its group. In the
case of nested groups, the group offsets add together. If an outer group has an
offset of 2, and an inner group an offset 3, any break tokens that produce line
breaks in the inner group will offset by 5 spaces (plus the break's offsets).
Additionally, a break that produces a line break immediately before an open
token will also increase the offset. For example, if a break has an offset of 2
immediately before an open with an offset of 3, the breaks within the group will
be offset by 5.

```
# open(consistent/inconsistent, offset)
Tokens = ["one", break, open(C, 2), "two", break, "three", close]

# Maximum line length of 10
Output =
"""
one
two
  three
"""

Tokens = ["one", break(offset=2), open(C, 0), "two", break, "three", close]

# Maximum line length of 10
Output =
"""
one
  two
  three
"""
```

The open token of a group is assigned the total size of the group as its length.
Open tokens must always be paired with a *close* token.

```
Tokens = ["one", break(1, 2), open(C, 2), "two", break(1, 2), "three", close]
Lengths = [3, 11, 10, 3, 1, 5, 0]
```

#### Close

The *close* tokens indicate the end of a group, and they have a length of zero.
They must always be paired with an *open* token.

#### Newline

The *newline* tokens behave much the same way as *break* tokens, except that
they always produce a line break. They can be assigned an offset, in the same
way as a break. They can also be given an integer number of line breaks to
produce.

These tokens are given a length equal to the maximum allowed line width. The
reason for this is to indicate that any enclosing groups are too large to fit on
a single line.

```
# Assume maximum line length of 50
# break(size)
Tokens = ["one", break(1), "two", break(1), open, "three", newline, "four", close]
Lengths = [3, 4, 3, 60, 59, 5, 50, 4, 0]
```

#### Space

*Space* tokens are used to insert whitespace between tokens, as you might do
with a *break* token. However, line-breaks may not occur at *space* tokens. They
have a size assigned to them, corresponding to the number of spaces you wish to
print.

#### Reset

Reset tokens are used to reset the state created by break tokens if needed, and
are rarely used. A primary use-case is to prevent an entire group from moving to
a new line, but you still want the group to break internally. Reset tokens have
a length of zero.

A reset token makes whatever follows it behave as if it was at the beginning of
the line.

```
Tokens = ["one", break(1), "two", reset]
Lengths = [3, 4, 3, 0]

# Normal breaking behavior of a consistent group
Tokens = ["one", break(1), open(C, 2), "two", break(1), "three", break(1), "four", close]
Output =
"""
one
  two
  three
  four
"""

# Breaking behavior of a consistent group with a reset token
Tokens = ["one", break(1), reset, open(C, 2), "two", break(1), "three", break(1), "four", close]
Output =
"""
one two
  three
  four
"""
```

#### Comment

Comment tokens represent Swift source comments, and they come in four types:
`line`, `docLine`, `block`, and `docBlock`. Their length is equal to the number
of characters needed to print them, including whitespace and delimiters. Line
comments produce one comment token per line. If other comment types span
multiple lines, their content is represented as a single comment token.

```
# Line comment
// comment 1
// comment 2
Tokens = [line(" comment 1"), newline, line(" comment 2")]

/// Doc comment 1
/// Second line
Tokens = [docLine(" Doc comment 1\n Second line")]

/* Block comment
   Second line */
Tokens = [block(" Block comment\n   Second Line ")]

/** Doc Block comment
  * Second line **/
Tokens = [docBlock(" Doc Block comment\n  * Second line *")]
```

#### Verbatim

Verbatim tokens are used to print text verbatim without any formatting apart
from applying a global indentation. They have a length set to the maximum line
width. They are typically used to handle syntax types that are classed as
"unknown" by SwiftSyntax. In these cases, we don't have access to the
substructure of the syntax node a manner useful for formatting, so we print them
verbatim. The indentation for verbatim tokens is applied to the first line of
the text. The relative indentation of subsequent lines is preserved unless they
have less indentation than the first line, in which case we set the indentation
of those lines equal to the first.

```
// Consider "ifnt", an unknown syntax structure:

if someCondition {
    ifnt anotherCondition {
      let a = 123
  let b = 456
    }
}

// The pretty-printer will transform this into:

if someCondition {
  ifnt anotherCondition {
    let a = 123
  let b = 456
  }
}
```

### Token Generation

Token generation begins with the abstract syntax tree (AST) of the Swift source
file, provided by the [SwiftSyntax](https://github.com/apple/swift-syntax)
library. We have overloaded a `visit` method for each of the different kinds of
syntax nodes. Most of these nodes are higher-level, and are composed of other
nodes. For example, `FunctionDeclSyntax` contains
`GenericParameterClauseSyntax`, `FunctionSignatureSyntax` nodes among others.
These member nodes are called via a call to `super.visit` at the end of the
function. That being said, we visit the higher level nodes before the lower
level nodes.

Within the visit methods, you can attach pretty-printing tokens at different
points within the syntax structures. For example, if you wanted to place an
indenting group around the body of a function declaration with consistent
breaking, and you want the trailing brace forced to the next line, it might look
like:

```
// In visit(_ node: FunctionDeclSyntax)
after(node.body?.leftBrace, tokens: .break(offset: 2), .open(.consistent, 0))
before(node.body?.rightBrace, tokens: .break(offset: -2), .close)
```

Two dictionaries are maintained to keep track of the pretty-printing tokens
attached to the syntax tokens: `beforeMap`, and `afterMap`. Calls to `before`
and `after` populate these dictionaries. In the above example, `node.body?` may
return `nil`, in which case `before` and `after` gracefully do nothing.

The lowest level in the AST is `TokenSyntax`, and it is at this point that we
actually add the syntax token and its attached pretty-printer tokens to the
output array. This is done in `visit(_ token: TokenSyntax)`. We first check the
syntax token's leading trivia for the presence of newlines and comments
(excluding end-of-line comments), and add corresponding printing tokens to the
output array. Next, we look at the token's entry in the `beforeMap` dictionary
and add any accumulated `before` tokens to the output array. Next, we add the
syntax token itself to the array. We look ahead to the leading trivia of the
next syntax token to check for an end-of-line comment, and we add it to the
array if needed. Finally, we add the `after` tokens. The ordering of the `after`
tokens is adjusted such that the token attached by lower level `visit` method
are added to the array before the higher level `visit` methods.

The only types of trivia we are interested in are newlines and comments. Since
these only appear as leading trivia, we don't need to look at trailing trivia.
It is important to note that `SwiftSyntax` always attaches comments as the
leading trivia on the following token.  Spaces are handled directly by inserting
`break` and `space` tokens, and backticks are handled in the *scan* and *print*
phases of the algorithm, after token generation.

When examining trivia for comments, a distinction is made for end-of-line
comments:

```
// not end-of-line
let a = 123  // end-of-line comment
let b = "abc"

// In the above example, "not end-of-line" is part of the leading trivia of
// "let" for "let a", and "end-of-line comment" is leading trivia for "let" of
// "let b".
```

A comment is determined to be end-of-line when it appears as the first item in a
token's leading trivia (it is not preceded by a newline, and we are not at the
beginning of a source file).

When we have visited all nodes in the AST, the array of printing tokens is then
passed on to the *scan* phase of the pretty-printer.

See: [`TokenStreamCreator.swift`](../Sources/SwiftFormatPrettyPrint/TokenStreamCreator.swift)

## Scan

The purpose of the scan phase is to calculate the lengths of all tokens;
primarily the `break` and `open` tokens. It takes as input the array of tokens
produced by `TokenStreamCreator`.

There are three main variables used in the scan phase: an index stack
(`delimIndexStack`), a running total of the lengths (`total`), and an array of
lengths (`lengths`). The index stack is used to store the locations of `open`
and `break` tokens, since we need to look back to fill in the lengths. The
running total adds the lengths of each token as we encounter it. The length
array is the same size as the token array, and stores the computed lengths of
the tokens.

After having iterated over the entire list of tokens and calculated their
lengths, we then loop over the tokens and call `print` for each token with its
corresponding length.

See: [`PrettyPrint.swift:prettyPrint()`](../Sources/SwiftFormatPrettyPrint/PrettyPrint.swift)

### Syntax Tokens

The length of a `syntax` token is the number of columns needed to print it. This
value goes directly into the length array, and `total` is incremented by the
same amount.

### Open Tokens

If we encounter an `open` token, we push its index onto `delimIndexStack`,
initialize its length to `-total`, and append this value to the length array.

### Close Tokens

At a `close` token, we pop an index off the top of the stack. This index will
correspond to either an `open` or `break` token. If it is an `open` token, we
add `total` to its length. The `total` variable will have been accumulating
lengths since encountering the `open` token. The `open` token's length is
`total_at_close - total_at_open` (hence the reason for initializing to
`-total`).

If the index is a `break`, we add `total` to its length. We pop the stack again
to get the location of the `open` token corresponding to this `close`. We are
guaranteed for this to be an `open` since any other `break` tokens will have
been handled by the logic in the next subsection.

### Break Tokens

If a `break` token is encountered, first check the top of the index stack. Only
if the index corresponds to another `break`, pop it from the stack, and add
`total` to its length. Initialize the length of the current `break` to `-total`
on the length array, push its index onto the stack, and then increment `total`
by the size of the `break`.

### Newline Tokens

A `newline` token executes the same logic as for `break` tokens. However, we
assign it a length equal to the maximum allowed line length, and increment
`total` by the same amount. We do not push its index onto the stack since we
already know its length and do not need to calculate it at a later time.

### Space Tokens

A `space` token has a length equal to its `size` value. This is appended to the
length array and added to `total`.

### Reset Tokens

If a `reset` token is encountered, check if the top of the index stack
corresponds to a `break`. If it does, pop it from the stack, and add `total` to
its length in the length array. Append a length of 0 to the length array for the
`reset` token.

### Comment Tokens

A `comment` token has a length equal to the number of characters required to
print it. This value is appended to the length array, and added to `total`.

### Verbatim Tokens

A `verbatim` token has a length equal to the maximum allowed line length. This
value is appended to the length array, and added to `total`.
