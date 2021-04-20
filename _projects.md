# Projects

Here are my noteworthy, publicly released personal projects, in varying
states of completion. Ordered roughly by date of creation:

## Bluebird (July 2020-present)

[Repository](https://github.com/csb6/bluebird)

An ahead-of-time compiler for a new programming language that resembles Ada and
C++. It is a front-end for the LLVM compiler toolchain (also used by the clang
C and C++ compiler project). My goal is to learn about compiler construction
and implement a language capable of expressing useful programs.

### Features

- Custom lexing, parsing, and semantic analysis stages
- Static type-checking and the ability to define custom types
- Generates LLVM intermediate representation, which is then translated to
stand-alone executables
- Debug support for gdb and lldb
- Several optimization passes, turned on with a command-line flag
- Support for the basic constructs of an imperative programming language
(e.g. mutable variables, while-loops, functions, integer/boolean/character 
types, a limited form of reference types, arrays)

### Language/Technologies

- C++
- LLVM
- GNU Multiple Precision Arithmetic Library

## HTML++ (June 2020)

[Repository](https://github.com/csb6/html-plus-plus)

A C++ template library that enables the writing of HTML documents using
nested C++ types. The end result after compiling is a C++ program that prints
out a properly-indented HTML document.

This was a test drive of C++20's expanded features, which more easily allow
for strings to be passed as non-type template parameters. This made it possible
to emulate the syntax of HTML tags (e.g. `<html><head></head></html>` in HTML becomes
`html<body<>, head<>>` in C++) using legal C++ code. While mostly intended as
a funny demonstration of how C++'s template system can be used beyond its
original purpose, the library does provide a degree of static type-checking that
HTML itself does not.

### Features

- Ability to generate basic tags, such as `<html>`, `<head>`, `<body>`, `<p>`,
`<h1>`, etc.
- Pretty prints properly-indented document

### Language/Technologies
- C++

## Editorial (November 2019-October 2020)

[Repository](https://github.com/csb6/editorial)

A simple `nano`-like text editor written using the ncurses library. It does
not have a large feature set, but works well for simple text editing.

### Features

- Syntax highlighting for C++, Markdown, and MIPS assembly
- Simple scrolling and undo functionality
- Generated syntax highlighting code
- Easily extendable syntax highlighting for other languages
- Compact and straightforward implementation - ~900 LOC
- Works well with large files

### Language/Technologies

- C++
- ncurses

## Editor (November-December 2019)

[Repository](https://github.com/csb6/editor)

Another text editor project, this time using the FLTK GUI library rather than
an ncurses UI. This was a great opportunity to learn more about working with
a mature open-source library's documentation (and all of the surprises that
come with it), as well as expand my experience with GUI programming.

### Features

- Custom coloring of text and background
- Basic Save, Save As, and Open operations for files, with keyboard shortcuts
- Basic support for font-loading
- Line numbers

### Language/Technologies

- C++
- FLTK

## Mail.py (May-June 2019)

[Repository](https://github.com/csb6/mail.py)

A bare-bones IMAP email client in Tkinter, still not feature-complete.
Right now, it supports loading/viewing the messages in an email
account's inbox and sending plain-text messages from the same account.

The purpose of this project was to see how far I could push my Python
skill set, and while I managed to get the very basic features implemented,
parsing messages, which come in a variety of HTML and plain-text formats,
proved difficult. Interacting with the IMAP protocol also took more effort
than I expected.

However, the client still works as a simple email inbox viewer and message
sender.

### Features

- Loads inbox into a local SQL database<
- Compose/send emails
- Uses Model-View-Adapter architecture to keep code decoupled
- Ability to view senders, subjects, time of sending for all messages

### Language/Technologies

- Python
- Tkinter
- IMAP
- SQLite
