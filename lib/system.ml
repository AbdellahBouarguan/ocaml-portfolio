(* Reads the first float from a file (useful for /proc/uptime) *)
let read_uptime () =
  try
    let ic = open_in "/proc/uptime" in
    let line = input_line ic in
    close_in ic;
    Scanf.sscanf line "%f" (fun u -> u)
  with _ -> 0.0

(* Formats seconds into 00h 00m *)
let format_uptime seconds =
  let hrs = int_of_float (seconds /. 3600.0) in
  let mins = int_of_float ((mod_float seconds 3600.0) /. 60.0) in
  Printf.sprintf "%dh %02dm" hrs mins

(* Simple parsing for /proc/meminfo to find MemTotal and MemAvailable *)
let read_memory () =
  try
    let ic = open_in "/proc/meminfo" in
    let rec loop total avail =
      try
        let line = input_line ic in
        let total = 
          if String.starts_with ~prefix:"MemTotal:" line then
            Scanf.sscanf line "MemTotal: %d kB" (fun x -> Some x)
          else total
        in
        let avail = 
          if String.starts_with ~prefix:"MemAvailable:" line then
            Scanf.sscanf line "MemAvailable: %d kB" (fun x -> Some x)
          else avail
        in
        match total, avail with
        | Some t, Some a -> (t, a)
        | _ -> loop total avail
      with End_of_file -> (0, 0)
    in
    let (t, a) = loop None None in
    close_in ic;
    (* Calculate used percentage *)
    if t > 0 then
      let used = t - a in
      int_of_float ((float_of_int used /. float_of_int t) *. 100.0)
    else 0
  with _ -> 0
