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
  let mins = int_of_float (mod_float seconds 3600.0 /. 60.0) in
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
        match (total, avail) with
        | Some t, Some a -> (t, a)
        | _ -> loop total avail
      with End_of_file -> (0, 0)
    in
    let t, a = loop None None in
    close_in ic;
    (* Calculate used percentage *)
    if t > 0 then
      let used = t - a in
      int_of_float (float_of_int used /. float_of_int t *. 100.0)
    else 0
  with _ -> 0

type cpu_time = { user : int; nice : int; system : int; idle : int }

let read_cpu () =
  try
    let ic = open_in "/proc/stat" in
    let line = input_line ic in
    close_in ic;
    Scanf.sscanf line "cpu %d %d %d %d" (fun u n s i ->
        { user = u; nice = n; system = s; idle = i })
  with _ -> { user = 0; nice = 0; system = 0; idle = 0 }

(* Store previous reading to calculate delta *)
let prev_cpu = ref (read_cpu ())

let get_cpu_usage () =
  let curr = read_cpu () in
  let prev = !prev_cpu in
  prev_cpu := curr;

  let prev_idle = prev.idle + prev.nice in
  let curr_idle = curr.idle + curr.nice in
  let prev_total = prev.user + prev.nice + prev.system + prev.idle in
  let curr_total = curr.user + curr.nice + curr.system + curr.idle in

  let total_diff = float_of_int (curr_total - prev_total) in
  let idle_diff = float_of_int (curr_idle - prev_idle) in

  if total_diff = 0.0 then 0
  else int_of_float ((total_diff -. idle_diff) /. total_diff *. 100.0)
