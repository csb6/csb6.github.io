<article>

## Introduction

[LR parsers](https://en.wikipedia.org/wiki/LR_parser) (including SLR, LALR, and canonical LR, among others)
provide an elegant and powerful method of parsing strings according to the rules of [context-free grammars](https://en.wikipedia.org/wiki/Context-free_grammar) (CFGs).

For conforming grammars, these parsers have runtimes that are linear in the number of input tokens. Efficient parsers can be generated automatically from grammar specifications. As an added benefit, the
generation process reveals ambiguities in the grammar, which helps uncover confusing or
unintuitive parts of the language's syntax. Crucially, the parse tree produced by LR parsers is guaranteed to be
the only possible parse tree that conforms to the grammar for that sequence of input tokens, giving every
valid input a canonical syntactic structure.

Because LR family parsers are so extensively studied, provide such useful guarantees, and relate so closely to
formal grammars, they are an ideal subject for formal specification and verification, as shown in the literature [^1].

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
we could create more concrete specifications (i.e. closer to an executable program) to use as the basis for
implementations and prove that the concrete specification is equivalent to the abstract specification. This process,
called [refinement](https://en.wikipedia.org/wiki/Refinement_(computing)), is beyond the scope of this article, however.

All of this means that our formal specifications are not very useful for space or complexity analysis - the specifications
are written in terms of mathematical structures that could describe the behavior of a variety of implementations. What
we are trying to do is treat our programs as mathematical formulas, not as individual operations for a machine to
perform.

## Notation

This article uses the [Vienna Development Method](https://en.wikipedia.org/wiki/Vienna_Development_Method)
specification language, or VDM-SL for short. VDM is derived from work on formal specification done at IBM in the 1970s,
making it one of the oldest formal methods. VDM-SL is based on [set theory](https://en.wikipedia.org/wiki/Set_theory) but with some important modifications. All values in the language have a type - types include basic
primitives found in most programming languages such as integers, rational numbers, and booleans as well as
composite types such as sets, unions, maps, records, and sequences. The language is very rich but has well-defined semantics and is suitable for formal proof.

If you are familiar with basic set theory and functional programming it should be easy to read the specifications I provide.

## Basic Data Types

### Terminals

The input to a parser is a stream of tokens, also known as *terminals*. While tokens are often characters from a text
encoding such as ASCII, language-specific tokens produced consist of the basic components of the language (such as
keywords, parentheses, numeric literals, etc.) can be used instead. These tokens are typically produced by a lexer. Our
approach assumes that we have enumerated the possible kinds of tokens - whatever they may be - and so we represent them
with a type called `Terminal`.

For example, a simple mathematical language might use the following definition:

```
Terminal = <Plus> | <Minus> | <Mult> | <Div> | <LParen> | <RParen> | <Digit>;
```

### Rules and Nonterminals

A grammar consists of a set of *rules* that associate so-called *nonterminals* with sequences of terminals
and/or nonterminals. We refer to the nonterminal part as the *left-hand side* or *lhs* of the rule, and the corresponding
sequence as the *right-hand side* or *rhs* of the rule. The same nonterminal can be the *lhs* of multiple rules.
Here is a VDM-SL type representing the nonterminals of a simple language:

```
Nonterminal = <Number> | <Sum> | <Product> | <Factor> | <START>;
```

While both terminals and nonterminals can appear on the *rhs* of a rule, they have different properties. Terminals
are by definition individual tokens, while nonterminals represent contiguous sections of the input that
match some rule found in the grammar. Ultimately, parsing is a process of checking that the entire input sequence matches
a rule that has a special nonterminal, `<START>`, as its *lhs*.

Below are definitions for the record type `Rule` as well as `Symbol`, which is a union of terminals and nonterminals.
The *rhs* is a sequence of zero or more `Symbol`s:

```
Symbol = Terminal | Nonterminal;
Rule :: lhs: Nonterminal
        rhs: seq of Symbol;
```

### Items

The process of matching a rule can be thought of as a series of steps: first, the first symbol of its *rhs* is
matched, then the second, and so on until all of the *rhs* has been matched against the input. Since we match the
symbols in order, starting from the first symbol (if any) of the *rhs*, all partial matches will be prefixes of the
*rhs* with the full match being the longest possible prefix. We call complete and in-progress matches *items* and
represent them with the following data type:

```
Item :: rule: Rule
        progress: nat
    inv item == item.progress <= len item.rule.rhs;
```

The `rule` field represents the rule we are attempting to match, while `progress` represents the extent of the match
so far. `progress` starts at 0 (no progress) and for each symbol of `rule`'s *rhs* that is matched `progress` becomes
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

</article>

[^1]: See ["Verified, Executable Parsing"](https://doi.org/10.1007/978-3-642-00590-9_12) by Barthwal and Norrish as well as ["Validating LR(1) Parsers"](https://doi.org/10.1007/978-3-642-28869-2_20) by Jourdan et al. These papers cover much more than just formal specifications for LR-family parsers - they describe methods of verifying the code derived from the specifications and also provide proofs of interesting properties about the specifications themselves.