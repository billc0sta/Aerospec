type t = {values: (string, (Value.t * bool)) Hashtbl.t; parent: t option;}

let make () = {values=(Hashtbl.create 16); parent=None}

let find ident env = Hashtbl.find_opt env.values ident

let add ident value env = Hashtbl.add env.values ident value

let remove ident env = Hashtbl.remove env.values ident

let replace ident value env = Hashtbl.replace env.values ident value

let child_of env =
	{(make ()) with parent=(Some env)}

let parent_of env =
	match env.parent with
	| None -> raise (Invalid_argument "Environment.parent_of")
	| Some env -> env

let _ = parent_of