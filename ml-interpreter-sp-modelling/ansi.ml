
(* ansi.ml *)

(* Define an enumerated type for ANSI colors *)
type ansi_color = 
  | Black 
  | Red 
  | Green 
  | Yellow 
  | Blue 
  | Magenta 
  | Cyan 
  | White 
  | HiBlack 
  | HiRed 
  | HiGreen 
  | HiYellow 
  | HiBlue 
  | HiMagenta 
  | HiCyan 
  | HiWhite
  | Default
  | Rgb of int * int * int  (* RGB color *)

(* Define an enumerated type for ANSI styles *)
type ansi_style = 
  | Reset 
  | RegText 
  | BoldText 
  | FaintText 
  | UnderlineText 
  | HighIntensityText 
  | BoldHighIntensityText 
  | UnderlineHighIntensityText

(* Define a gfx_state structure to manage combinations of styles and colors *)
type gfx_state = {
  bold : bool;
  faint : bool;
  underline : bool;
  fg : ansi_color;
  bg : ansi_color;
}

(* Default graphic state *)
let default_gfx_state = {
  bold = false;
  faint = false;
  underline = false;
  fg = Default;
  bg = Default;
}

(* Function to convert ansi_style to its escape code *)
let style_to_code = function
  | Reset -> "\027[0m"
  | RegText -> "\027[0;"
  | BoldText -> "\027[1;"
  | FaintText -> "\027[2;"
  | UnderlineText -> "\027[4;"
  | HighIntensityText -> "\027[0;9"
  | BoldHighIntensityText -> "\027[1;9"
  | UnderlineHighIntensityText -> "\027[4;9"

(* Function to convert ansi_color to its escape code *)
let color_to_code = function
  | Black -> "30"
  | Red -> "31"
  | Green -> "32"
  | Yellow -> "33"
  | Blue -> "34"
  | Magenta -> "35"
  | Cyan -> "36"
  | White -> "37"
  | HiBlack -> "90"
  | HiRed -> "91"
  | HiGreen -> "92"
  | HiYellow -> "93"
  | HiBlue -> "94"
  | HiMagenta -> "95"
  | HiCyan -> "96"
  | HiWhite -> "97"
  | Default -> "39"
  | Rgb (r, g, b) -> Printf.sprintf "38;2;%d;%d;%d" r g b  (* RGB escape code *)

(* Function to combine style and color into a full ANSI escape code *)
let ansi style color =
  if style = Reset then
    style_to_code style
  else
    Printf.sprintf "%s%s" (style_to_code style) (color_to_code color) ^ "m"

(* Function to style text with the given ANSI style and color *)
let style_text style color text =
  let reset = ansi Reset Default in
  let colored_text = ansi style color in
  Printf.sprintf "%s%s%s" colored_text text reset

(* Function to combine foreground and background colors *)
let ansi_with_bg style fg bg =
  let reset = ansi Reset Default in
  let fg_code = ansi style fg in
  let bg_code = Printf.sprintf "\027[%sm" (color_to_code bg) in
  Printf.sprintf "%s%s" fg_code bg_code

(* Function to style text with foreground and background colors *)
let style_text_with_bg style fg bg text =
  let reset = ansi Reset Default in
  let fg_bg_text = ansi_with_bg style fg bg in
  Printf.sprintf "%s%s%s" fg_bg_text text reset

(* Apply gfx_state to generate the complete ANSI sequence for the current state *)
let apply_gfx_state state text =
  let fg_color = ansi RegText state.fg in
  let bg_color = Printf.sprintf "\027[%sm" (color_to_code state.bg) in
  let bold_code = if state.bold then "\027[1m" else "" in
  let faint_code = if state.faint then "\027[2m" else "" in
  let underline_code = if state.underline then "\027[4m" else "" in
  let reset = ansi Reset Default in
  Printf.sprintf "%s%s%s%s%s%s%s" fg_color bg_color bold_code faint_code underline_code text reset

(* Function to apply specific text formatting using gfx_state *)
let style_text_with_state state text =
  apply_gfx_state state text

(* Function to parse RGB color *)
let parse_rgb r g b = Rgb (r, g, b)