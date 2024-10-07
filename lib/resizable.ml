type 'a t = {mutable arr: 'a array; mutable size: int}

let make () = {arr = [||]; size=0}

let resize rez size default =
	let new_arr = Array.make size default in
	Array.blit rez.arr 0 new_arr 0 rez.size;
	rez.arr <- new_arr 

let append rez elem =
	if rez.size = Array.length rez.arr 
		then resize rez (max 8 (rez.size*2)) elem;
	rez.arr.(rez.size) <- elem;
	rez.size <- rez.size + 1
	
let insert rez index elem =
	if index < 0 || index >= rez.size then
		raise (Invalid_argument "Resizable.insert")
	else
	if rez.size = Array.length rez.arr 
		then resize rez (max 8 (rez.size*2)) elem;
	let rec aux i prev =
		if i > rez.size then () else
		let newel = rez.arr.(i) in
		rez.arr.(i) <- prev;
		aux (i+1) newel
	in aux index elem;
	rez.size <- rez.size + 1

let extend rez rez2 =
	if rez.size = 0 && rez2.size = 0 then () else
	let default = if rez.size = 0 then rez2.arr.(0) else rez.arr.(0) in
	let comb_cap = rez.size + rez2.size in
	let rez_cap = Array.length rez.arr in
	if rez_cap < comb_cap then resize rez (max (rez_cap * 2) comb_cap) default;
	for i=0 to rez2.size - 1 do
		rez.arr.(i+rez.size) <- rez2.arr.(i)
	done;
	rez.size <- rez.size + rez2.size

let merge rez1 rez2 = 
	let new_rez = make () in
	if rez1.size = 0 && rez2.size = 0 then new_rez else
	let default = if rez1.size = 0 then rez2.arr.(0) else rez1.arr.(0) in
	resize new_rez (rez1.size+rez2.size) default;
	for i=0 to rez1.size - 1 do
		append new_rez rez1.arr.(i) 
	done;
	for i=0 to rez2.size - 1 do
		append new_rez rez2.arr.(i) 
	done;
	new_rez

let index rez elem = 
	let rec aux i =
		if i = rez.size then -1 else
		if rez.arr.(i) = elem 
		then i
		else aux (i+1)
	in aux 0

let pop rez index =
	if index < 0 || index >= rez.size then
	raise (Invalid_argument "Resizable.pop")
	else 
	for i=index to rez.size - 1 do
		rez.arr.(i) <- rez.arr.(i+1);
	done;
	rez.size <- rez.size - 1

let remove rez elem =
	let i = index rez elem in
	if  i = -1 then () else
	pop rez i

let clear rez = rez.size <- 0

let count rez elem = 
	let rec aux acc i =
		if i = rez.size then acc else
		let acc = if rez.arr.(i) = elem then acc + 1 else acc
		in aux acc (i+1)
	in aux 0 0

let len rez = rez.size 

let get rez index = 
	if index < 0 || index >= rez.size then
	raise (Invalid_argument "Resizable.get: index out of bounds")
	else rez.arr.(index)

let putat rez index elem =
	if index < 0 || index >= rez.size then
	raise (Invalid_argument "Resizable.get: index out of bounds") 
	else rez.arr.(index) <- elem

let range rez beginning ending =
	if beginning < 0 || beginning >= len rez || 
		 ending < 0 || ending > len rez ||
		 ending < beginning then
		raise (Invalid_argument "Resizable.range: index out of bounds")
	else
	let new_rez = make () in
	resize new_rez (ending - beginning) rez.arr.(0);
	new_rez.size <- ending - beginning;
	for i = beginning to ending - 1 do
		new_rez.arr.(i-beginning) <- rez.arr.(i);
	done; new_rez 

let iter f rez =
	for i = 0 to (len rez - 1) do
		f (get rez i);
	done