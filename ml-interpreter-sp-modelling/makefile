make: build
	./tansh

build:
	ocamlc -c ansi.ml
	ocamlc -c ast.ml
	ocamlc -c distributions.ml
	ocamlc -c eval.ml
	ocamlyacc parser.mly
	ocamlc -c parser.mli
	ocamlc -c parser.ml
	ocamllex lexer.mll
	ocamlc -c lexer.ml
	ocamlc -c repl.ml
	ocamlc -c main.ml
	ocamlfind ocamlc -linkpkg -package unix -o tansh ansi.cmo ast.cmo distributions.cmo eval.cmo parser.cmo lexer.cmo repl.cmo  main.cmo 

clean:
	rm -f lexer.ml parser.ml parser.mli
	rm -f *.c*
	rm -f tansh