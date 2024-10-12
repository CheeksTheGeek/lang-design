# Lang Design: A Monorepo for Language Interpreters and Compilers

Welcome to **Lang Design**, a monorepo where I explore the design and implementation of various programming language interpreters and compilers. This repository hosts projects that span the entire spectrum of programming languages — from general-purpose languages like C, Python, Rust, and Haskell, to domain-specific languages such as VHDL and Verilog. My work here includes both widely-known languages and languages I've created for specialized purposes.

## Repository Structure

The monorepo is structured to house individual language projects, each containing its own interpreter or compiler. Below are the key projects:

```
.
├── ml-compiler-for-c          # OCaml compiler for a subset of C (MLCC)
│   ├── README.md
│   ├── ast.ml                 # Abstract Syntax Tree for the C language
│   ├── codegen.ml             # Code generation for C into assembly
│   ├── lexer.mll              # Lexical analyzer for C
│   ├── main.ml                # Main driver for the compiler
│   ├── makefile               # Build instructions
│   ├── parser.mly             # Parser for C
│   ├── sample.c               # Example C input
│   └── sample_gold.s          # Example expected assembly output
├── ml-interpreter-sp-modelling # Tansh: Probabilistic Modelling Interpreter
│   ├── README.md
│   ├── ansi.ml                # ANSI color and text styling functions
│   ├── ast.ml                 # Abstract Syntax Tree for the Tansh language
│   ├── distributions.ml       # Probability distribution functions
│   ├── eval.ml                # Interpreter/evaluator for Tansh
│   ├── lexer.mll              # Lexical analyzer for Tansh
│   ├── main.ml                # Main driver for the interpreter
│   ├── makefile               # Build instructions
│   ├── parser.mly             # Parser for Tansh
│   └── repl.ml                # Read-Eval-Print-Loop (REPL) implementation
```

## Projects

### 1. **ML Compiler for C (MLCC)**

This project is an OCaml-based compiler for a subset of the C language, showcasing the compilation process from source code to assembly. It includes:

- **Abstract Syntax Tree (AST)** for parsing C code.
- **Code generation** to convert C into assembly.
- **Lexer and parser** for tokenizing and analyzing C syntax.
  
You can find a sample C program (`sample.c`) and its expected assembly output (`sample_gold.s`) in this project.

### 2. **Tansh: A Stochastic Modelling and Statistical Language Interpreter**

Tansh (Turing Approximation for Non-deterministic Stochastic Heuristics) is a custom language designed to model stochastic processes, probabilistic algorithms, and basic machine learning models. It supports:

- **Probabilistic distributions** like Bernoulli, Uniform, and Gaussian.
- **Basic machine learning models**, including Logistic Regression and K-Means clustering.
- **Functional programming constructs** like lambda calculus, conditional expressions, and recursion.

The project is implemented in OCaml, featuring a REPL interface with ANSI color enhancements for improved user interaction.

## Upcoming and Future Projects

The **Lang Design** monorepo is intended to grow and encompass compilers and interpreters for a variety of languages, spanning both general-purpose and specific-purpose domains. The goal is to explore different paradigms and extremes of the language spectrum.

### Potential Languages to Explore:
- **General-Purpose Languages**:
  - Python
  - C / C++
  - Rust
  - Haskell
  - Lisp (Common Lisp, Scheme)
  - Go
  - OCaml
  - Swift
  - JavaScript
  
- **Specific-Purpose Languages**:
  - VHDL (Hardware description language)
  - Verilog / SystemVerilog (Hardware modeling and design)
  - SQL (Database querying)
  - LaTeX (Typesetting)
  - Bash (Shell scripting)
  
- **Other Extremes**:
  - Brainfuck (Esoteric programming)
  - Malbolge (Difficult-to-program language)
  - Assembly (Low-level programming)

As the repository expands, I aim to include new interpreters, compilers, and even custom-designed languages tailored for specific problem domains.

## Getting Started

To get started with any of the projects, clone the repository and follow the individual `README.md` instructions within each subdirectory.

1. **Clone the repo**:

   ```bash
   git clone git@github.com:CheeksTheGeek/lang-design.git
   cd lang-design
   ```

2. **Navigate to a specific project**:

   ```bash
   cd ml-compiler-for-c    # Example for the C compiler project
   ```

3. **Build and run the project** using the provided Makefile:

   ```bash
   make
   ./your_executable  # Replace with the appropriate executable (e.g., tansh for the Tansh project)
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.