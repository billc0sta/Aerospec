
type ('a, 'b) t = {values: ('a, 'b) Hashtbl.t; parent: ('a, 'b) t option;}

let make () = {values=(Hashtbl.create 8); parent=None}

let find ident env = Hashtbl.find_opt env.values ident

let add ident value env = Hashtbl.add env.values ident value

let remove ident env = Hashtbl.remove env.values ident

let replace ident value env = Hashtbl.replace env.values ident value

let search ident env =
  let rec aux env =
    match env with
    | None -> None
    | Some env -> begin
        match find ident env with
        | None -> aux env.parent
        | Some v -> Some (env, v)
      end
  in aux (Some env)

let child_of env =
  {(make ()) with parent=(Some env)}

let parent_of env =
  match env.parent with
  | None -> raise (Invalid_argument "Environment.parent_of")
  | Some env -> env

let _ = parent_of
