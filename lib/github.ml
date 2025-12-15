open Lwt.Infix
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

(* 1. Define the Data Structure *)
type repo = {
  name : string;
  html_url : string;
  description : string option;
  language : string option;
  stargazers_count : int;
  topics : string list option; (* Added topics field *)
}
[@@deriving yojson] [@@yojson.allow_extra_fields]

type response = repo list [@@deriving yojson]

(* 2. The Fetching Logic *)
let fetch_repos username =
  let headers = Cohttp.Header.init_with "User-Agent" "OCaml-Portfolio" in
  let url =
    Uri.of_string
      ("https://api.github.com/users/" ^ username ^ "/repos?sort=updated")
  in

  Cohttp_lwt_unix.Client.get ~headers url >>= fun (resp, body) ->
  let code = resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status in

  if code = 200 then
    Cohttp_lwt.Body.to_string body >|= fun json_str ->
    let json = Yojson.Safe.from_string json_str in
    response_of_yojson json
  else Lwt.return []

(* 3. The Caching Logic *)
let cache : response option ref = ref None
let last_fetch_time = ref 0.0
let cache_duration = 3600.0 (* 1 hour *)

let fetch_repos_cached username =
  let current_time = Unix.time () in
  match !cache with
  | Some data when current_time -. !last_fetch_time < cache_duration ->
      Lwt.return data
  | _ ->
      let%lwt data = fetch_repos username in
      cache := Some data;
      last_fetch_time := current_time;
      Lwt.return data

(* 4. Filtering Logic *)
(* Only keep repos that have the topic "portfolio-featured" *)
let filter_featured repos =
  List.filter
    (fun r ->
      match r.topics with
      | Some t -> List.mem "portfolio-featured" t
      | None -> false)
    repos
