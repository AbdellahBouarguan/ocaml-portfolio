(* Helper to convert a repo to HTML *)
let render_repo (repo : Github.repo) =
  let desc = Option.value ~default:"No description" repo.description in
  let lang = Option.value ~default:"Text" repo.language in
  Format.sprintf
    {|
    <article>
      <header>
        <strong>%s</strong>
        <span style="float:right; font-size: 0.8rem">⭐ %d</span>
      </header>
      <p>%s</p>
      <footer>
        <small>%s</small>
        <a href="%s" role="button" class="secondary outline" target="_blank" style="float:right">View Code</a>
      </footer>
    </article>
    |}
    repo.name repo.stargazers_count desc lang repo.html_url

(* --- Add this ABOVE the views --- *)

type category = Language | System | Tool | Security
type skill = { name : string; category : category; level : int (* 1 to 100 *) }

let my_skills =
  [
    { name = "OCaml"; category = Language; level = 25 };
    { name = "C / C++"; category = Language; level = 45 };
    { name = "Python"; category = Language; level = 65 };
    { name = "GNU/Linux"; category = System; level = 75 };
    { name = "Network Analysis"; category = Security; level = 25 };
    { name = "Git & GitHub"; category = Tool; level = 25 };
    { name = "Docker"; category = Tool; level = 10 };
  ]

let string_of_category = function
  | Language -> "Languages"
  | System -> "Systems"
  | Tool -> "Dev Tools"
  | Security -> "Cybersecurity"

(* Helper to render a single skill bar *)
let render_skill s =
  let cat_color =
    match s.category with
    | Language -> "#e63946" (* Red *)
    | System -> "#f1faee" (* White/Light *)
    | Security -> "#a8dadc" (* Cyan *)
    | Tool -> "#457b9d" (* Blue *)
  in
  Format.sprintf
    {|
    <div style="margin-bottom: 1rem;">
      <div style="display:flex; justify-content:space-between;">
        <strong>%s</strong>
        <small>%s</small>
      </div>
      <progress value="%d" max="100" style="--pico-primary: %s"></progress>
    </div>
    |}
    s.name
    (string_of_category s.category)
    s.level cat_color

(* The View Handler *)
(* --- 1. System Status Handler --- *)
let status_view _req =
  let uptime_sec = System.read_uptime () in
  let uptime_str = System.format_uptime uptime_sec in
  let ram_usage = System.read_memory () in

  (* Determine color based on load *)
  let ram_color =
    if ram_usage > 80 then "#ef4444" (* Red *) else "#10b981" (* Green *)
  in

  Dream.html
    (Format.sprintf
       {|
    <div style="font-family: monospace; font-size: 0.8rem; border-top: 1px solid #333; padding-top: 10px; margin-top: 2rem; color: #64748b;">
      <span style="margin-right: 15px;">
        🖥️ <strong>Uptime:</strong> %s
      </span>
      <span>
        📊 <strong>RAM:</strong> <span style="color: %s">%d%%</span>
      </span>
      <span style="float:right">
        Running on OCaml 5.x
      </span>
    </div>
    |}
       uptime_str ram_color ram_usage)

(* --- 2. Projects View Handler --- *)
let projects_view _req =
  let username = "AbdellahBouarguan" in

  let%lwt repos = Github.fetch_repos username in

  let list_html =
    match repos with
    | [] -> "<p>No repositories found (or API limit reached).</p>"
    | _ -> String.concat "\n" (List.map render_repo repos)
  in

  Dream.html list_html

(* --- Static Views (Unchanged) --- *)

let home_template =
  {|
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CS Portfolio</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css">
    <script src="https://unpkg.com/htmx.org@1.9.6"></script>
    <style>
       nav { border-bottom: 1px solid #333; padding-bottom: 1rem; margin-bottom: 2rem; }
       .htmx-indicator { opacity: 0; transition: opacity 200ms ease-in; }
       .htmx-request .htmx-indicator { opacity: 1; } 
    </style>
  </head>
  <body>
    <main class="container">
      <hgroup>
        <h1>My CS Portfolio</h1>
        <h2>Systems Engineering & Functional Programming</h2>
      </hgroup>
      
      <nav>
        <ul>
          <li>
            <a href="#" 
               hx-get="/projects" 
               hx-target="#content"
               hx-indicator="#loading">Projects</a>
          </li>
          <li><a href="#" hx-get="/skills" hx-target="#content">Skills</a></li>
          <li><a href="#" hx-get="/contact" hx-target="#content">Contact</a></li>
        </ul>
      </nav>

      <div id="loading" class="htmx-indicator">
        <article aria-busy="true">Fetching data from GitHub API...</article>
      </div>

      <div id="content">
        <p>Welcome. Select a tab to load content.</p>
      </div>

      <footer 
        hx-get="/status" 
        hx-trigger="load, every 2s" 
        hx-swap="innerHTML">
        Loading System Status...
      </footer>
    </main>
  </body>
  </html>
  |}

(* --- The New Skills View Handler --- *)

let skills_view _req =
  let skills_html = String.concat "\n" (List.map render_skill my_skills) in
  Dream.html
    (Format.sprintf
       {|
      <article>
        <header><strong>Technical Expertise</strong></header>
        <div class="grid">
          <div>%s</div>
        </div>
      </article>
      |}
       skills_html)

let contact_view _req =
  Dream.html
    {|
  <article>
    <h3>Hire Me</h3>
    <ul>
      <li><a href="https://linkedin.com">LinkedIn</a></li>
      <li><a href="https://upwork.com">Upwork</a></li>
    </ul>
  </article>
  |}

let home_view _req = Dream.html home_template
