# HakLisp: A Haskell Lisp Interpreter

Welcome to the **HakLisp**, a simple yet powerful Lisp interpreter implemented in Haskell. This project aims to provide a foundational Lisp environment, showcasing the beauty of functional programming and the flexibility of Lisp's syntax and semantics.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
  - [Running the REPL](#running-the-repl)
  - [REPL Commands](#repl-commands)
  - [Loading Lisp Scripts](#loading-lisp-scripts)
  - [Example Scripts](#example-scripts)
- [Project Structure](#project-structure)

## Features

- **Basic Data Types:** Supports atoms, numbers, booleans, strings, lists, and dotted lists.
- **Variable Definitions:** Define and set variables using `(define ...)` and `(set ...)`.
- **Lambda Functions:** Create anonymous functions with `(lambda ...)` and support for closures.
- **Built-in Primitives:** Arithmetic operations (`+`, `-`, `*`, `/`), comparison operators (`=`, `<`, `>`, `<=`, `>=`), and logical operators (`&&`, `||`).
- **Conditional Expressions:** Evaluate expressions conditionally using `(if ...)`.
- **File Loading:** Load and execute Lisp scripts from files using `(load "filename.lisp")`.
- **REPL (Read-Eval-Print Loop):** Interactive shell for executing Lisp expressions.
- **Comment Support:** Recognizes and ignores comments starting with `;`.

## Getting Started

Follow these instructions to set up and run the Haskell Lisp Interpreter on your local machine.

### Prerequisites

- **Haskell Stack:** Ensure you have [Haskell Stack](https://docs.haskellstack.org/en/stable/README/) installed. Stack is a build tool for Haskell projects.

  ```bash
  # For macOS using Homebrew
  brew install haskell-stack

  # For other platforms, refer to the official installation guide:
  # https://docs.haskellstack.org/en/stable/README/#how-to-install
  ```

- **Git:** Version control system to clone the repository.

  ```bash
  # For macOS using Homebrew
  brew install git

  # For other platforms, refer to the official installation guide:
  # https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
  ```

### Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/chaitanyasharma/lisp-interpreter.git
   cd lisp-interpreter
   ```

2. **Build the Project:**

   Use Stack to build the project. This will download necessary dependencies and compile the interpreter.

   ```bash
   stack build
   ```

   **Note:** The first build may take some time as Stack downloads and compiles all dependencies.

3. **Run the Interpreter:**

   After a successful build, you can run the interpreter using:

   ```bash
   stack exec lisp-interpreter
   ```

   This will launch the interactive REPL.

## Usage

Once you've built and run the interpreter, you can start executing Lisp expressions interactively.

### Running the REPL

To start the REPL, execute:

```bash
stack exec lisp-interpreter
```

**Sample Output:**

```bash
Welcome to the Haskell Lisp Interpreter!
Lisp>>> 
```

### REPL Commands

- **Define a Variable:**

  ```lisp
  (define x 10)
  ```

  **Output:**

  ```
  10
  ```

- **Set an Existing Variable:**

  ```lisp
  (set x 20)
  ```

  **Output:**

  ```
  20
  ```

- **Define a Function:**

  ```lisp
  (define add (lambda (a b) (+ a b)))
  ```

  **Output:**

  ```
  <lambda>
  ```

- **Call a Function:**

  ```lisp
  (add 5 7)
  ```

  **Output:**

  ```
  12
  ```

- **Conditional Expression:**

  ```lisp
  (if (> x 15) "Greater" "Smaller or Equal")
  ```

  **Output:**

  ```
  "Greater"
  ```

- **Load a Lisp Script:**

  ```lisp
  (load "examples/hello_world.lisp")
  ```

  **Output:**

  ```
  "Hello, World!"
  <lambda>
  "Hello, World!"
  ```

- **Exit the REPL:**

  ```lisp
  :quit
  ```

  **Output:**

  ```
  Goodbye!
  ```

### Loading Lisp Scripts

You can write Lisp scripts in `.lisp` files and load them into the interpreter using the `(load "filename.lisp")` command.

**Example: `examples/hello_world.lisp`**

```lisp
; This is a simple hello world example in Lisp

(define greeting "Hello, World!") ; Define a greeting variable

(define (print-greeting)
  (print greeting)) ; Define a function to print the greeting

(print-greeting) ; Call the function
```

**Loading the Script:**

```lisp
(load "examples/hello_world.lisp")
```

**Output:**

```
"Hello, World!"
<lambda>
"Hello, World!"
```

### Example Scripts

The `examples/` directory contains sample Lisp scripts demonstrating various features of the interpreter. Feel free to explore and modify them to test different functionalities.

- **`hello_world.lisp`**: A basic script to define and print a greeting.
- **`math_operations.lisp`**: Demonstrates arithmetic and comparison operations.
- **`functions.lisp`**: Showcases function definitions and higher-order functions.

## Project Structure

Here's an overview of the project's directory structure:

```
lisp-interpreter/
├── LICENSE               # (Optional) License file.
├── README.md             # Project documentation.
├── stack.yaml            # Stack configuration.
├── package.yaml          # Package configuration.
├── src/
│   ├── Main.hs           # Entry point of the application.
│   ├── AST.hs            # Abstract Syntax Tree definitions.
│   ├── Environment.hs    # Environment management.
│   ├── Evaluator.hs      # Evaluation logic.
│   ├── Parser.hs         # Parsing logic.
│   ├── REPL.hs           # Read-Eval-Print Loop implementation.
│   └── Types.hs          # Shared type definitions.
├── test/
│   └── Spec.hs           # Test suite.
├── examples/
│   ├── hello_world.lisp  # Example Lisp script.
│   ├── math_operations.lisp
│   └── functions.lisp
└── .gitignore            # Git ignore rules.
```

### Module Descriptions

- **`Types.hs`**: Centralizes shared type definitions like `Env` and `LispVal` to prevent circular dependencies and ambiguity across modules.

- **`AST.hs`**: Defines the Abstract Syntax Tree (AST) structures for Lisp expressions. Currently re-exports `LispVal` from `Types.hs`.

- **`Environment.hs`**: Manages the mutable environment using `IORef`. Handles variable definitions, lookups, and updates.

- **`Evaluator.hs`**: Contains the core evaluation logic, processing Lisp expressions within the environment.

- **`Parser.hs`**: Implements parsing of Lisp code into AST structures. Supports comments and multiple expressions.

- **`REPL.hs`**: Provides the interactive shell interface for users to input and execute Lisp expressions.

- **`Main.hs`**: The entry point of the application, initiating the REPL.

- **`test/`**: Contains the test suite to ensure the correctness of the interpreter's components.

- **`examples/`**: Houses sample Lisp scripts demonstrating various interpreter features.

### Adding New Tests

1. **Open `test/Spec.hs`:**

   ```haskell
   module Main where

   import Test.Hspec
   import Evaluator (eval)
   import Environment (initEnv)
   import Types (LispVal(..))
   
   main :: IO ()
   main = hspec $ do
     describe "Evaluator" $ do
       it "evaluates numbers correctly" $ do
         env <- initEnv
         eval env (Number 5) `shouldReturn` Right (Number 5)
       
       it "evaluates arithmetic expressions correctly" $ do
         env <- initEnv
         eval env (List [Atom "+", Number 2, Number 3]) `shouldReturn` Right (Number 5)
       
       it "handles undefined variables" $ do
         env <- initEnv
         eval env (Atom "x") `shouldReturn` Left "Unbound variable: x"
       
       -- Add more test cases as needed
   ```

2. **Add More Cases:**

   Expand the test suite by adding more `it` blocks to cover different functionalities like conditionals, function definitions, closures, etc.