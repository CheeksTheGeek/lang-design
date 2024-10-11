# C Compiler in OCaml

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Language](https://img.shields.io/badge/language-OCaml-orange.svg)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-green.svg)

Welcome to the **C Compiler in OCaml** project! This compiler is a minimalistic implementation of a C compiler written in OCaml, targeting AArch64 architecture. It showcases the fundamental aspects of compiler design, including lexing, parsing, abstract syntax tree (AST) construction, semantic analysis, and code generation.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Project Structure](#project-structure)
- [Component Overview](#component-overview)
  - [Abstract Syntax Tree (`ast.ml`)](#abstract-syntax-tree-astml)
  - [Lexer (`lexer.mll`)](#lexer-lexermll)
  - [Parser (`parser.mly`)](#parser-parsermly)
  - [Code Generator (`codegen.ml`)](#code-generator-codegenml)
  - [Main Driver (`main.ml`)](#main-driver-mainml)
  - [Makefile](#makefile)
  - [Sample C Program (`sample.c`)](#sample-c-program-samplec)
  - [Expected Assembly Output (`sample_gold.s`)](#expected-assembly-output-sample_golds)
- [Building the Compiler](#building-the-compiler)
- [Testing the Compiler](#testing-the-compiler)
- [Accomplishments](#accomplishments)
- [Future Work](#future-work)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Introduction

This project serves as an educational tool for understanding how compilers work under the hood. It compiles a subset of the C language into AArch64 assembly, focusing on integer arithmetic, control flow constructs, and basic variable management.

## Features

- **Lexical Analysis**: Tokenizes the input C code.
- **Parsing**: Constructs an AST from tokens.
- **Semantic Analysis**: Basic type checking and validation.
- **Code Generation**: Outputs AArch64 assembly code.
- **Control Structures**: Supports `if`, `else`, `while`, `for`, `return`, `break`, and `continue`.
- **Expressions**: Handles binary and unary operations.
- **Variables**: Supports variable declarations and assignments.
- **Functions**: Can compile functions with parameters and return values.

## Project Structure

```bash
.
├── ast.ml
├── codegen.ml
├── lexer.mll
├── main.ml
├── makefile
├── parser.mly
├── sample.c
└── sample_gold.s
```

## Component Overview

### Abstract Syntax Tree (`ast.ml`)

Defines the data structures used to represent the program's syntax and semantics.

- **Types**: Represents data types like `int`, `float`, `char`, and `void`.
- **Expressions**: Defines literals, variables, binary and unary operations, function calls, and assignments.
- **Statements**: Includes expression statements, return statements, conditional statements (`if`, `else`), loops (`while`, `for`), and block statements.
- **Declarations**: Handles variable and function declarations.
- **Program**: Represents the entire program as a list of declarations.

### Lexer (`lexer.mll`)

Responsible for converting the input C code into a stream of tokens.

- **Tokens**: Recognizes keywords, identifiers, literals, operators, and punctuation.
- **Whitespace Handling**: Skips over spaces, tabs, newlines, and carriage returns.
- **Comments**: Supports both single-line (`//`) and multi-line (`/* ... */`) comments.

### Parser (`parser.mly`)

Parses the stream of tokens produced by the lexer to build the AST.

- **Grammar Rules**: Defines the syntax of the supported C subset.
- **Error Handling**: Reports syntax errors with line and character positions.
- **Operator Precedence**: Manages the precedence and associativity of operators.

### Code Generator (`codegen.ml`)

Generates AArch64 assembly code from the AST.

- **Register Management**: Uses a set of registers (`X0` to `X15`) for computation.
- **Instruction Generation**: Translates AST nodes into assembly instructions.
- **Control Flow**: Handles conditional jumps and labels for `if` statements and loops.
- **Function Prologue/Epilogue**: Manages stack frame setup and teardown.

### Main Driver (`main.ml`)

The entry point of the compiler.

- **File Handling**: Reads the input C file specified in the command line arguments.
- **Compilation Pipeline**: Coordinates lexing, parsing, and code generation.
- **Error Reporting**: Provides detailed error messages for both lexing and parsing stages.

### Makefile

Automates the build process.

- **Targets**:
  - `all`: Builds the compiler and compiles `sample.c` to produce an executable.
  - `clean`: Removes compiled artifacts.
  - `distclean`: Performs a deep clean, including the compiler executable.
- **Variables**: Configurable settings for the compiler, flags, files, and object files.

### Sample C Program (`sample.c`)

A simple C program used to test the compiler.

```c
int main() {
    int x = 5;
    int y = 10;
    int result = x + y;

    if (result > 10) {
        return result;
    } else {
        return 0;
    }
}
```

### Expected Assembly Output (`sample_gold.s`)

The ideal assembly code generated by Clang for `sample.c`, used as a reference to compare the compiler's output.

## Building the Compiler

### Prerequisites

- **OCaml**: Make sure OCaml and its associated tools (`ocamlc`, `ocamlyacc`, `ocamllex`) are installed.
- **Clang**: Required for assembling and linking the generated assembly code.

### Steps

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/c-compiler-ocaml.git
   cd c-compiler-ocaml
   ```

2. **Build the Compiler**

   Run the `make` command to build the compiler and compile the sample program.

   ```bash
   make
   ```

   This command performs the following:

   - Compiles the OCaml source files.
   - Generates the lexer and parser from `lexer.mll` and `parser.mly`.
   - Links the object files to create the `mlcc` compiler executable.
   - Uses `mlcc` to compile `sample.c` into `sample.s`.
   - Assembles and links `sample.s` using Clang to create the executable `sample`.

3. **Run the Sample Program**

   ```bash
   ./sample
   echo $?
   ```

   The `echo $?` command prints the exit status of the `sample` executable, which represents the `return` value from the `main` function.

## Testing the Compiler

You can test the compiler with different C programs by following these steps:

1. **Create a New C File**

   Write your C code in a new file, for example, `test.c`.

2. **Compile the C File**

   Use the `mlcc` compiler to compile your C file into assembly.

   ```bash
   ./mlcc test.c > test.s
   ```

3. **Assemble and Link**

   Use Clang to assemble and link the generated assembly code.

   ```bash
   clang -o test test.s
   ```

4. **Run the Program**

   ```bash
   ./test
   echo $?
   ```

   Check the output and exit status to verify correctness.

## Accomplishments

- **Functional Compiler Pipeline**: Successfully implemented a compiler pipeline from lexing to code generation.
- **AArch64 Assembly Generation**: The compiler can generate assembly code for the AArch64 architecture.
- **Control Flow Constructs**: Implemented `if-else` statements and loops.
- **Variable Management**: Supports variable declarations, assignments, and arithmetic operations.
- **Function Handling**: Can compile functions with parameters and return statements.
- **Error Handling**: Provides informative error messages during lexing and parsing.

## Future Work

- **Enhanced Type Checking**: Implement comprehensive semantic analysis for type checking and scope resolution.
- **Additional Language Features**: Support more C features like arrays, pointers, structs, and function calls with arguments.
- **Optimizations**: Implement code optimizations for better performance and efficiency.
- **Cross-Platform Support**: Extend support to other architectures like x86_64.
- **Intermediate Representation**: Introduce an intermediate representation (IR) for more advanced optimizations and analyses.