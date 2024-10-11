{ (* lexer.mll *)
  open Parser
  exception Error of string
}

rule read = parse
  | [' ' '\t' '\r' '\n'] { read lexbuf } (* skip whitespace *)
  | ['0'-'9']+ ('.' ['0'-'9']+)? as num { FLOAT (float_of_string num) } (* float *)
  | ['a'-'z' 'A'-'Z' '_']['a'-'z' 'A'-'Z' '0'-'9' '_']* as id { (* identifier *)
      match id with 
      | "let" -> LET
      | "in" -> IN
      | "if" -> IF
      | "then" -> THEN
      | "else" -> ELSE
      | "fun" -> FUN
      | "true" -> TRUE
      | "false" -> FALSE
      | _ -> IDENT id (* all other identifiers *)
    }
  | "+" { PLUS }
  | "-" { MINUS }
  | "*" { TIMES }
  | "/" { DIVIDE }
  | "=" { EQUAL }
  | "<" { LESS }
  | ">" { GREATER }
  | "->" { ARROW }
  | "(" { LPAREN }
  | ")" { RPAREN }
  | eof { EOF }
  | _ as char { raise (Error (Printf.sprintf "Unknown character: %c" char)) }
