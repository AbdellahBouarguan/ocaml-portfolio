open Lwt.Infix
open Ppx_yojson_conv_lib.Yojson_conv.Primitives

(* 1. Define the Data Structure *)
(* Added [@@yojson.allow_extra_fields] so it ignores junk data from GitHub *)
type repo = {
  name : string;
  html_url : string;
  description : string option;
  language : string option;
  stargazers_count : int;
} [@@deriving yojson] [@@yojson.allow_extra_fields]

type response = repo list [@@deriving yojson]

(* 2. The Fetching Logic *)
let fetch_repos username =
  (* Added User-Agent header which is REQUIRED by GitHub API *)
  let headers = Cohttp.Header.init_with "User-Agent" "OCaml-Portfolio" in
  let url = Uri.of_string ("https://api.github.com/users/" ^ username ^ "/repos?sort=updated") in
  
  Cohttp_lwt_unix.Client.get ~headers url >>= fun (resp, body) ->
  let code = resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status in
  
  if code = 200 then
    Cohttp_lwt.Body.to_string body >|= fun json_str ->
    let json = Yojson.Safe.from_string json_str in
    response_of_yojson json
  else
    (* If it fails (e.g. rate limit), return empty list *)
    Lwt.return []
