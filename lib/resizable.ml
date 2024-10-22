type 'a t = {mutable arr: 'a array; mutable size: int}

let make () = {arr = [||]; size=0}

let resize rez size default =
  let new_arr = Array.make size default in
  Array.blit rez.arr 0 new_arr 0 rez.size;
  rez.arr <- new_arr 

let copy rez = {arr=Array.copy rez.arr; size=rez.size}

let append rez elem =
  if rez.size = Array.length rez.arr 
  then resize rez (max 8 (rez.size*2)) elem;
  rez.arr.(rez.size) <- elem;
  rez.size <- rez.size + 1

let insert rez index elem =
  if index < 0 || index >= rez.size then
	raise (Invalid_argument "Resizable.insert: oob")
  else
	if rez.size = Array.length rez.arr 
	then resize rez (max 8 (rez.size*2)) elem;
  let rec aux i prev =
	if i > rez.size then () else
      begin
	    let newel = rez.arr.(i) in
	    rez.arr.(i) <- prev;
	    aux (i+1) newel
      end
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
	for i=index to rez.size - 2 do
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
    begin
	  let new_rez = make () in
	  resize new_rez (ending - beginning) rez.arr.(0);
	  new_rez.size <- ending - beginning;
	  for i = beginning to ending - 1 do
	    new_rez.arr.(i-beginning) <- rez.arr.(i);
	  done; new_rez
    end

let shrink rez =
  if rez.size = 0 
  then rez.arr <- [||]
  else
    begin
	  let	new_arr = Array.make rez.size rez.arr.(0) in
	  Array.blit rez.arr 0 new_arr 0 rez.size;
	  rez.arr <- new_arr
    end

let iter f rez =
  for i = 0 to (len rez - 1) do
	f (get rez i);
  done

let insert_rez rez1 rez2 index =
  if index < 0 || index > rez1.size then
	ignore(raise (Invalid_argument "Resizable.insert_rez: oob")); 
  let (lrz1, lrz2) = (len rez1, len rez2) in
  if lrz2 = 0 then () else
    begin
      while (Array.length rez1.arr) < lrz1 + lrz2 do
        resize rez1 (max 8 (Array.length rez1.arr * 2)) (get rez2 0);
      done;
      Array.blit rez1.arr index rez1.arr (index+lrz2) (lrz1-index);
      Array.blit rez2.arr 0 rez1.arr index lrz2;
      rez1.size <- lrz1 + lrz2
    end

let index_rez rez1 rez2 =
  let lrz1 = len rez1 in
  let lrz2 = len rez2 in
  if lrz1 = 0 || lrz2 = 0
  then -1
  else 
  let rec aux p1 p2 =
    if p2 = lrz2 then p1 - lrz2
    else if p1 = lrz1 then (-1)
    else match (get rez1 p1, get rez2 p2) with
             | (c1, c2) when c1 = c2 -> aux (p1+1) (p2+1)
             | _ -> aux (p1+1) 0
  in aux 0 0

let remove_rez rez1 rez2 =
  let lrz1 = len rez1 in
  let lrz2 = len rez2 in
  let iof2 = index_rez rez1 rez2 in
  if lrz1 = 0 || lrz2 = 0 || iof2 = (-1) 
  then ()
  else
    begin
      Array.blit rez1.arr (iof2+lrz2) rez1.arr iof2 (lrz1-(iof2+lrz2));
      rez1.size <- rez1.size - lrz2
    end

let equal rez1 rez2 =
  let lrz1 = len rez1 in
  let lrz2 = len rez2 in
  if lrz1 <> lrz2 then false
  else
    let rec aux i =
      if i = lrz1 then true
      else if (get rez1 i) = (get rez2 i)
      then aux (i+1)
      else false
    in aux 0

let compare f rez1 rez2 =
  let lrz1 = len rez1 in
  let lrz2 = len rez2 in
  if lrz1 > lrz2 then 1
  else if lrz1 < lrz2 then -1
  else
    let rec aux i =
      if i = lrz1 then 0 else 
      let x = f (get rez1 i) (get rez2 i) in
      if x <> 0 then x
      else aux (i+1)
    in aux 0
