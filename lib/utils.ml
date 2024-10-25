let get_line start_pos program =
  let rec aux start_pos end_pos = 
	let nstart_pos = if start_pos - 1 < 0 || program.[start_pos-1] = '\n' then start_pos else start_pos - 1 in
	let nend_pos = if end_pos + 1 >= String.length program || program.[end_pos+1] = '\n' then end_pos else end_pos + 1 in
	if nstart_pos = start_pos && nend_pos = end_pos then
	  (nstart_pos, nend_pos)
	else
	  aux nstart_pos nend_pos
  in 
  let (start_pos, end_pos) = aux start_pos start_pos in
  String.sub program (start_pos) (end_pos - start_pos)

let read_whole_file filename =
  let ch = open_in_bin filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let rec list_dup_at f = function
  | [] -> None
  | x::xs -> if List.exists (fun y -> (f x) = (f y)) xs then (Some (f x)) else list_dup_at f xs
