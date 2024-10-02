type 'a t = {arr: 'a array; size: int}


let make () = {arr = [||]; size=0}

let append rez elem =
	let rez = if rez.size = Array.length rez.arr 
		then resize rez (rez.size*2)
		else rez
	in
	rez.arr.(rez.size) <- elem in
	{rez with size = rez.size+1}
	
let insert rez index elem =
	let rez = if rez.size = Array.length rez.arr 
		then resize rez (rez.size*2)
		else rez
	in
	let rec aux i prev =
		if i > rez.size then () else
		let newel = rez.arr.(i) in
		rez.arr.(i) <- prev;
		aux (i+1) newel
	in aux index elem;
	{rez with size = res.size+1}

let extend rez rez2 =
	let rez =
	let comb_cap = rez.size + rez2.size in
	let rez_cap = Array.length rez.arr in
	if rez_cap > comb_cap 
		then 
			let new_cap = if comb_cap < rez_cap * 2 then rez_cap * 2 else comb_cap in
			resize rez new_cap 
		else 
			rez
	in
	let rec aux i1 i2 =
		if i2 = rez2.size then () else
		rez.arr.(i1) <- rez2.arr.(i2);
		aux (i1+1) (i2+1)
	in aux rez.size 0;
	{rez with size=rez.size + rez2.size}

let remove rez elem =
	
	
let index rez elem = 

let pop rez index = 

let clear rez =

let count rez = 

let len rez = 
