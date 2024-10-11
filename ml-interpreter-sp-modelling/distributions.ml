let flip p =
  Random.float 1.0 < p

let uniform a b =
  Random.float (b -. a) +. a

let gaussian mu sigma =
  let rec box_muller () =
    let u = Random.float 1.0 in
    let v = Random.float 1.0 in
    let s = u *. u +. v *. v in
    if s >= 1.0 || s = 0.0 then box_muller ()
    else
      let multiplier = sqrt (-2.0 *. log s /. s) in
      u *. multiplier
  in
  mu +. sigma *. box_muller ()