# Tansh: A Stochastic Modeling and Statistical Language Interpreter

**Tansh** (Turing Approximation for Non-deterministic Stochastic Heuristics) is a probabilistic modeling language and interpreter that supports a range of statistical operations, probability distributions, and stochastic processes. Designed with a REPL interface, Tansh enables interactive modeling of random variables, probabilistic algorithms, and statistical evaluations, all within a concise, easy-to-use syntax. It serves as both an educational tool and a functional interpreter for exploring random processes, making it ideal for statisticians, data scientists, and researchers.

## Key Features

- **Statistical Expressions and Operations**: Supports core mathematical operations like addition, subtraction, multiplication, and division, alongside logical operations such as equality (`=`, `<`, `>`).
- **Probabilistic Distributions**: Includes built-in support for common probability distributions such as:
  - **Bernoulli**: via the `flip` function.
  - **Uniform**: for continuous uniform random variables.
  - **Gaussian (Normal)**: supporting both mean (`mu`) and standard deviation (`sigma`).
- **Lambda Calculus Support**: Implements functional constructs like `let`, `if-then-else`, lambda abstractions (`fun`), and function applications.
- **Interactive REPL**: A responsive Read-Eval-Print-Loop (REPL) for real-time interpretation and evaluation of probabilistic models, featuring intuitive feedback and ANSI-enhanced text formatting.
- **ANSI Text Styling**: Enhanced user interface experience with color-coded output for improved readability and clarity of interactions.

## Getting Started

### Prerequisites

- **OCaml**: Ensure you have OCaml installed on your system, as Tansh is written entirely in OCaml and depends on its compiler toolchain.
  
### Building Tansh

1. **Clone the repository**:

   ```bash
   git clone https://github.com/yourusername/tansh-interpreter.git
   cd tansh-interpreter
   ```

2. **Compile the project** using the provided `Makefile`:

   ```bash
   make
   ```

   This will compile all modules, including the ANSI handling, abstract syntax tree (AST), distributions, lexer, parser, evaluator, and the main REPL driver.

3. **Run the interpreter**:

   ```bash
   ./tansh
   ```

### Example Usage

Once inside the REPL, you can start defining random variables, performing computations, and experimenting with distributions.

#### Basic Arithmetic Operations

```plaintext
 > let x = 5 + 3 in x
8
 > let y = 10.0 - 4.2 in y
5.8
```

#### Using Probability Distributions

- **Bernoulli Distribution**:

```plaintext
 > flip 0.5
true
```

- **Uniform Distribution**:

```plaintext
 > uniform 0.0 1.0
0.6245
```

- **Gaussian Distribution**:

```plaintext
 > gaussian 0.0 1.0
-0.4321
```

#### Defining Functions and Conditionals

```plaintext
 > fun f x -> if x > 0 then x else -x
<function>

 > f 5
5

 > f -3
3
```

## Project Structure

```bash
.
├── ansi.ml            # ANSI color and text styling functions
├── ast.ml             # Abstract Syntax Tree (AST) definitions
├── distributions.ml   # Probabilistic distribution functions
├── eval.ml            # Interpreter/evaluator for Tansh expressions
├── lexer.mll          # Lexer for tokenizing input
├── main.ml            # Main driver, initializes the REPL
├── makefile           # Build system
├── parser.mly         # Parser definitions
├── repl.ml            # REPL implementation
```

### Core Modules

- **`ansi.ml`**: Provides a comprehensive suite for ANSI text formatting, including color and style management, to make REPL output more intuitive.
- **`ast.ml`**: Defines the language's syntax and structure, including core expression types such as `Let`, `If`, `Fun`, and probabilistic expressions like `Flip`, `Uniform`, and `Gaussian`.
- **`distributions.ml`**: Implements core probabilistic distributions, including Bernoulli, Uniform, and Gaussian.
- **`eval.ml`**: The interpreter itself, which evaluates Tansh expressions within an environment, supports function application, and manages variable bindings.
- **`lexer.mll` & `parser.mly`**: Define the language's grammar and syntax, converting source text into an Abstract Syntax Tree (AST).
- **`repl.ml`**: The Read-Eval-Print-Loop for interactive execution, with real-time feedback and error handling.

## Future Improvements

- **Expanded Probability Distributions**: Future versions of Tansh will include support for more complex distributions, including Poisson, Exponential, and Beta distributions.
- **Advanced Type System**: Adding static type inference and error checking to catch mistakes before runtime.
- **Compositional Models**: Introducing Bayesian inference and model composition to build complex probabilistic models.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.