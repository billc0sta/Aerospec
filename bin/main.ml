open Upl

let () = if Array.length Sys.argv < 2 then
  print_string "Aerospec: No program file was provided\n"
else
	try 
	let file_path = Sys.argv.(1) in
  let program   = Utils.read_whole_file file_path in
  Exec.execute program file_path false
	with Sys_error _ -> print_string "Aerospec: No such file"