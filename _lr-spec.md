<article>

## Introduction

[LR parsers](https://en.wikipedia.org/wiki/LR_parser) (including SLR, LALR, and canonical LR, among others)
provide an elegant and powerful method of parsing strings using [context-free grammars](https://en.wikipedia.org/wiki/Context-free_grammar) (CFGs).

For conforming grammars, these parsers have runtimes that are linear in the number of input tokens. Efficient parsers can be generated automatically from grammar specifications. As an added benefit, the
generation process reveals ambiguities in the grammar, which helps uncover confusing or
unintuitive parts of the language's syntax. Crucially, the parse tree produced by LR parsers is guaranteed to be
the only possible parse tree that conforms to the grammar for that sequence of input tokens, giving every
valid input a canonical syntactic structure.

Because LR family parsers are so extensively studied, provide such useful guarantees, and relate so closely to
formal grammars, they are an ideal subject for formal specification and verification. [^1]

While the members of the LR family accept different subsets of CFGs and vary significantly in their construction, the core concepts of each parser are very similar, and parser variants are often extensions of simpler variants. This enables us to formally specify them elegantly and reuse many of the same definitions for each variant.

## Why Write a Formal Specification?

While LR parsers have been the subject of many papers and books, I have found that most sources describe them
somewhat informally using pseudocode or natural language and often mix implementation details into their
descriptions. While convenient for parser generator implementers, mixing concerns in this way obscures
the mathematical structure of the parsers and the properties of those structures (some of which might prove
useful in deriving an efficient implementation). My belief is that by first describing things precisely, we can
program with more confidence and fewer bugs.

An important thing to keep in mind is that our specifications are not intended to be executed. Often they
can be, but sometimes they are too abstract (e.g. a function that is defined by its pre- and post-conditions but
has no actual body) or too inefficient (e.g. a map data structure that uses sets as its keys). At a later stage
we could create more concrete specification (i.e. closer to an executable program) to use as the basis for
implementations and prove that it is equivalent to the abstract specification. This process,
called [refinement](https://en.wikipedia.org/wiki/Refinement_(computing)), is beyond the scope of this article, however.

All of this means that our formal specifications are not very useful for space or complexity analysis - the specifications
are written in terms of mathematical structures that could describe the behavior of a variety of implementations. What
we are trying to do is treat our programs as mathematical formulas, not as individual operations for a machine to
perform.

## Notation

This article uses the [Vienna Development Method](https://en.wikipedia.org/wiki/Vienna_Development_Method)
specification language, or VDM-SL for short. VDM is derived from work on formal specification done at IBM in the 1970s,
making it one of the oldest formal methods. VDM-SL is based on a form of [set theory](https://en.wikipedia.org/wiki/Set_theory). All values in the language have a type. Types include basic
primitives found in most programming languages such as integers, rational numbers, and booleans as well as
composite types such as sets, unions, maps, records, and sequences. The language is very rich but has well-defined semantics and is suitable for formal proof.

If you are familiar with basic set theory and functional programming it should be easy to read the specifications I provide. For more information about VDM-SL, see this [great resource](https://www.overturetool.org/languages/).

## Basic Data Types

### Terminals

The input to a parser is a stream of tokens, also known as *terminals*. While tokens can be characters, e.g. from the
ASCII encoding, language-specific tokens for each of the basic components of the syntax (such as
keywords, parentheses, punctuation, numeric literals, etc.) are usually used instead. These tokens are
produced by a [lexer](https://en.wikipedia.org/wiki/Lexical_analysis). Our approach assumes that there are a finite
number of possible kinds of tokens - whatever they may be - and so we represent them with an enumerated type
called `Terminal`.

For example, a simple mathematical language might use the following definition:

```
Terminal = <Plus> | <Minus> | <Mult> | <Div> | <LParen> | <RParen> | <Digit>;
```

### Rules and Nonterminals

A grammar consists of a set of *rules* that associate so-called *nonterminals* with sequences of terminals
and/or nonterminals. We refer to the nonterminal part as the *left-hand side* or *lhs* of the rule, and the corresponding
sequence as the *right-hand side* or *rhs* of the rule. A nonterminal can be the *lhs* of multiple different rules.
Here is a VDM-SL type representing the nonterminals of a simple language:

```
Nonterminal = <Number> | <Sum> | <Product> | <Factor> | <START>;
```

Terminals and nonterminals can both appear on the *rhs* of a rule, but they have different properties. Terminals
are by definition individual tokens and so always represent a single matched token from the input. Nonterminals are more
flexible - each represents a contiguous section of the input matching a rule found in the grammar. Ultimately,
parsing is a process of checking that the entire input stream matches a rule that has a special nonterminal,
`<START>`, as its *lhs*.

Below are definitions for the record type `Rule` as well as `Symbol`, which is a union of terminals and nonterminals.
The *rhs* is a sequence of zero or more `Symbol`s:

```
Symbol = Terminal | Nonterminal;
Rule :: lhs: Nonterminal
        rhs: seq of Symbol;
```

### Items

The process of matching a rule can be thought of as a series of steps: first, the first symbol of its *rhs* is
matched, then the second, and so on until all of the *rhs* has been matched against the input. We call matches
(either complete or in-progress) *items* and represent them with the following data type:

```
Item :: rule: Rule
        progress: nat
    inv item == item.progress <= len item.rule.rhs;
```

The `rule` field represents the rule we are attempting to match and `progress` represents the extent of the match
so far. `progress` starts at 0 (no progress) and for each symbol of `rule`'s *rhs* that is matched `progress` is
one greater. A completed item's `progress` field equals the length of the *rhs* - the invariant (`inv`) in the definition
means that items must not progress past the end of the *rhs*, for such an item would no longer match the rule.

Now that we have defined the `Item` type, let's define some functions that will be useful later on.

First, we have `nextSym`. It returns the next symbol to be matched if the item is incomplete.
If the item is complete, it returns a special `nil` value. If you are familiar with functional languages, think of
`nextSym` as having `Optional` or `Maybe` as its return type:

```
nextSym: Item -> [Symbol]
nextSym(item) ==
    if item.progress < len item.rule.rhs then
        item.rule.rhs(item.progress+1)
    else nil;
```

Next, we have `isComplete`, which returns true if the item is complete and false otherwise:

```
isComplete: Item -> bool
isComplete(item) == nextSym(item) = nil;
```

`advanceItem` creates a new `Item` with its progress advanced one step forward. Note the precondition,
which requires that this function only be applied to an item that is incomplete:

```
advanceItem: Item -> Item
advanceItem(item) == mk_Item(item.rule, item.progress+1)
pre item.progress < len item.rule.rhs;
```

We will refer to these helper functions throughout the rest of the article.

## LR(0) Parsers

The simplest member of the LR family is the LR(0) parser. LR(0) means "left-to-right, rightmost derivation
with zero tokens of lookahead". This means the token stream is consumed starting from the left [^2] and moving to the
right, that the rightmost branch of each node of the parse tree is recognized first, and that only the tokens that
have been read so far are used to make parsing decisions.

LR(0) parsers, like all LR family parsers, are [shift-reduce parsers](https://en.wikipedia.org/wiki/Shift-reduce_parser).
This means that each token of input triggers either a *shift* action, which pushes the token onto a stack of
symbols representing the parse state so far, or a *reduce* action, which pops some number of symbols off of the stack
that represent the *rhs* of some rule in the grammar and replaces them with the *lhs* of that rule. Once the entire
input stream has been reduced down to a single `<START>` symbol, representing the root node of the full parse tree,
the parse is successful and complete.

This forces us to consider: how do we determine whether to shift or whether to reduce given a particular token and
a particular state of the stack?

Intuitively, it is easy to see one way to track the progress of a parse is to track `Item`s produced from the
input stream. Each token consumed either matches or doesn't match the `nextSym` of an in-progress `Item`, and
after reducing a completed `Item` into its *lhs* we might need to create new items to track. (TODO: maybe write
a naive parser that does this? Then show how that parser can be reduced into an equivalent table?)

To determine when to shift and when to reduce, we will use a state machine in the form of a transition table. Each
grammar will need to have its own transition table generated, but this table can be reused once generated.




</article>

[^1]: See ["Verified, Executable Parsing"](https://doi.org/10.1007/978-3-642-00590-9_12) by Barthwal and Norrish as well as ["Validating LR(1) Parsers"](https://doi.org/10.1007/978-3-642-28869-2_20) by Jourdan et al. These papers cover much more than just formal specifications for LR-family parsers - they describe methods of verifying the code derived from the specifications and also provide proofs of interesting properties about the specifications themselves.

[^2]: Consuming tokens from "left to right" means consuming them starting at the beginning of the input stream
and moving towards the end, regardless of the actual [writing direction](https://en.wikipedia.org/wiki/Writing_system#Directionality_and_orientation) of the language.