# Tansh: A Stochastic Modeling, Statistical, and Machine Learning Language Interpreter

**Tansh** (Turing Approximation for Non-deterministic Stochastic Heuristics) is an advanced probabilistic modeling and machine learning language interpreter. It supports statistical operations, probability distributions, stochastic processes, and basic machine learning algorithms. With its interactive REPL interface, Tansh enables modeling random variables, building machine learning models, and performing statistical evaluations in a concise and user-friendly syntax. It serves as both an educational tool and a functional interpreter for statisticians, data scientists, and machine learning practitioners.

## Key Features

- **Statistical Expressions and Operations**: Tansh supports core mathematical operations such as addition, subtraction, multiplication, and division, alongside logical operations such as equality (`=`, `<`, `>`).
- **Probabilistic Distributions**: Includes built-in support for common probability distributions such as:
  - **Bernoulli**: via the `flip` function for binary outcomes.
  - **Uniform**: for continuous uniform random variables.
  - **Gaussian (Normal)**: supporting both mean (`mu`) and standard deviation (`sigma`).
- **Basic Machine Learning Models**:
  - **Logistic Regression**: Supports binary classification with built-in training and prediction functionality.
  - **K-Means Clustering**: Perform unsupervised clustering on multi-dimensional data.
- **Lambda Calculus Support**: Implements functional constructs like `let`, `if-then-else`, lambda abstractions (`fun`), and function applications.
- **Interactive REPL**: A responsive Read-Eval-Print-Loop (REPL) for real-time interpretation, evaluation, and interaction with probabilistic and machine learning models, featuring intuitive feedback and ANSI-enhanced text formatting.
- **ANSI Text Styling**: Provides color-coded output for enhanced readability and a user-friendly interaction experience.

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

   This will compile all modules, including the ANSI handling, abstract syntax tree (AST), distributions, machine learning models, lexer, parser, evaluator, and the main REPL driver.

3. **Run the interpreter**:

   ```bash
   ./tansh
   ```

### Example Usage

Once inside the REPL, you can start defining random variables, building machine learning models, performing computations, and experimenting with distributions.

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

#### Machine Learning Models

- **Logistic Regression**:

  Train a binary classifier using logistic regression.

```plaintext
 > let features = [[1.0, 2.0], [1.5, 1.8], [5.0, 8.0], [8.0, 8.0]] in
   let labels = [0, 0, 1, 1] in
   let model = logistic_regression(features, labels) in
   predict_logistic(model, [2.0, 2.0])
0.45
```

- **K-Means Clustering**:

  Perform unsupervised clustering on multi-dimensional data.

```plaintext
 > let data = [[1.0], [1.5], [3.0], [5.0], [3.5], [4.5], [3.5]] in
   let kmeans_model = kmeans(data, 2) in
   get_clusters(kmeans_model)
[[1.5]; [4.0]]
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
- **`ast.ml`**: Defines the language's syntax and structure, including core expression types such as `Let`, `If`, `Fun`, and probabilistic expressions like `Flip`, `Uniform`, `Gaussian`, as well as machine learning constructs like `LogisticRegression` and `KMeans`.
- **`distributions.ml`**: Implements core probabilistic distributions, including Bernoulli, Uniform, and Gaussian.
- **`eval.ml`**: The interpreter itself, which evaluates Tansh expressions within an environment, supports machine learning models, function application, and variable bindings.
- **`lexer.mll` & `parser.mly`**: Define the language's grammar and syntax, converting source text into an Abstract Syntax Tree (AST).
- **`repl.ml`**: The Read-Eval-Print-Loop for interactive execution, with real-time feedback, machine learning model handling, and error handling.

## Future Improvements

- **Expanded Probability Distributions**: Future versions of Tansh will include support for more complex distributions, including Poisson, Exponential, and Beta distributions.
- **Advanced Type System**: Adding static type inference and error checking to catch mistakes before runtime.
- **More Machine Learning Models**: Implementing additional machine learning algorithms such as decision trees, support vector machines, and neural networks.
- **Model Visualization**: Adding graphical output to visualize machine learning model performance or clustering results.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.