%{ (* parser.mly *)
  open Ast
%}

%token <float> FLOAT
%token <string> IDENT
%token LET IN IF THEN ELSE FUN
%token TRUE FALSE
%token PLUS MINUS TIMES DIVIDE EQUAL LESS GREATER ARROW
%token LPAREN RPAREN
%token EOF

%start main
%type <Ast.expr> main

%left EQUAL LESS GREATER
%left PLUS MINUS
%left TIMES DIVIDE
%right ARROW

%%

main:
  | expr EOF { $1 }

expr:
  | LET IDENT EQUAL expr IN expr { Let($2, $4, $6) }
  | IF expr THEN expr ELSE expr { If($2, $4, $6) }
  | FUN IDENT ARROW expr { Fun($2, $4) }
  | comparison_expr { $1 }

comparison_expr:
  | comparison_expr EQUAL additive_expr { Eq($1, $3) }
  | comparison_expr LESS additive_expr { Lt($1, $3) }
  | comparison_expr GREATER additive_expr { Gt($1, $3) }
  | additive_expr { $1 }

additive_expr:
  | additive_expr PLUS multiplicative_expr { Add($1, $3) }
  | additive_expr MINUS multiplicative_expr { Sub($1, $3) }
  | multiplicative_expr { $1 }

multiplicative_expr:
  | multiplicative_expr TIMES application_expr { Mul($1, $3) }
  | multiplicative_expr DIVIDE application_expr { Div($1, $3) }
  | application_expr { $1 }

application_expr:
  | application_expr primary_expr { App($1, $2) }
  | primary_expr { $1 }

primary_expr:
  | FLOAT { Float($1) }
  | IDENT { Var($1) }
  | LPAREN expr RPAREN { $2 }
