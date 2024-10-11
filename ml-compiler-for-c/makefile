# Compiler and flags
OCAMLC = ocamlc
OCAMLYACC = ocamlyacc
OCAMLLEX = ocamllex
FLAGS = -g

# Files
LEXER = lexer.mll
PARSER = parser.mly
AST_ML = ast.ml
MAIN = main.ml
EXEC = mlcc

# Generated files
LEXER_ML = lexer.ml
PARSER_ML = parser.ml
PARSER_MLI = parser.mli

SAMPLE = sample
SAMPLE_C = $(SAMPLE).c
SAMPLE_S = $(SAMPLE).s

NATIVE_COMPILER = clang

# Object files
OBJ_FILES = ast.cmo lexer.cmo parser.cmo codegen.cmo main.cmo 

# Target to build the compiler
all: $(EXEC)
	./$(EXEC) $(SAMPLE_C) > $(SAMPLE_S)
	$(NATIVE_COMPILER) -o $(SAMPLE) $(SAMPLE_S)
	@echo "Compiled $(SAMPLE_C) to $(SAMPLE), you can run it with ./$(SAMPLE), and check the output with echo \$$?."
# Rule to generate the lexer
$(LEXER_ML): $(LEXER)
	$(OCAMLLEX) $(LEXER)

# Rule to generate the parser
$(PARSER_ML) $(PARSER_MLI): $(PARSER)
	$(OCAMLYACC) $(PARSER)

# Rule to compile the AST implementation
ast.cmo: $(AST_ML)
	$(OCAMLC) $(FLAGS) -c $(AST_ML)

# Rule to compile the parser interface
parser.cmi: $(PARSER_MLI)
	$(OCAMLC) $(FLAGS) -c $(PARSER_MLI)

# Rule to compile the lexer
lexer.cmo: $(LEXER_ML) parser.cmi
	$(OCAMLC) $(FLAGS) -c $(LEXER_ML)

# Rule to compile the parser implementation
parser.cmo: $(PARSER_ML) parser.cmi ast.cmo
	$(OCAMLC) $(FLAGS) -c $(PARSER_ML)

# Rule to compile the main file
main.cmo: $(MAIN) ast.cmo lexer.cmo parser.cmo
	$(OCAMLC) $(FLAGS) -c $(MAIN)

codegen.cmo: codegen.ml
	$(OCAMLC) $(FLAGS) -c codegen.ml

# Link the object files and create the final executable
$(EXEC): $(OBJ_FILES)
	$(OCAMLC) $(FLAGS) -o $(EXEC) $(OBJ_FILES)

# Clean the build files
clean:
	rm -f *.cmi *.cmo *.o $(LEXER_ML) $(PARSER_ML) $(PARSER_MLI) $(EXEC)
	rm -f $(SAMPLE)
	rm -f $(SAMPLE_S)

# give the c file to the compiler
sample: $(EXEC)
	./$(EXEC) $(SAMPLE_C)

sample_run: sample
	$(NATIVE_COMPILER) -o $(SAMPLE) $(
	./$(SAMPLE)
# Clean everything including the executable
distclean: clean
	rm -f $(EXEC)