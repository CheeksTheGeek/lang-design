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
      | "logistic_regression" -> LOGISTIC_REGRESSION
      | "predict_logistic" -> PREDICT_LOGISTIC
      | "kmeans" -> KMEANS
      | "get_clusters" -> GET_CLUSTERS

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
  | "[" { LBRACKET }   (* new: list start *)
  | "]" { RBRACKET }  (* new: list end *)
  | "," { COMMA }     (* new: comma *)
  | eof { EOF }
  | _ as char { raise (Error (Printf.sprintf "Unknown character: %c" char)) }
