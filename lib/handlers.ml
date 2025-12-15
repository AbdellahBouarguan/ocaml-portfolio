(* --- Helpers --- *)
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

type category = Language | System | Tool | Security
type skill = { name : string; category : category; level : int }

let my_skills =
  [
    { name = "OCaml"; category = Language; level = 85 };
    { name = "C / C++"; category = Language; level = 90 };
    { name = "Manjaro Linux"; category = System; level = 95 };
    { name = "Network Analysis"; category = Security; level = 75 };
    { name = "Git & GitHub"; category = Tool; level = 85 };
  ]

let string_of_category = function
  | Language -> "Languages"
  | System -> "Systems"
  | Tool -> "Dev Tools"
  | Security -> "Cybersecurity"

let render_skill s =
  let cat_color =
    match s.category with
    | Language -> "#e63946"
    | System -> "#f1faee"
    | Security -> "#a8dadc"
    | Tool -> "#457b9d"
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

(* --- Views --- *)

let status_view _req =
  let uptime_sec = System.read_uptime () in
  let uptime_str = System.format_uptime uptime_sec in
  let ram_usage = System.read_memory () in
  let ram_color = if ram_usage > 80 then "#ef4444" else "#10b981" in
  let cpu_usage = System.get_cpu_usage () in
  let cpu_color = if cpu_usage > 80 then "#ef4444" else "#10b981" in
  Dream.html
    (Format.sprintf
       {|
    <div style="font-family: monospace; font-size: 0.8rem; border-top: 1px solid #333; padding-top: 10px; margin-top: 2rem; color: #64748b;">
      <span style="margin-right: 15px;">🖥️ <strong>Uptime:</strong> %s</span>
      <span>⚙️ <strong>CPU:</strong> <span style="color: %s"> %d%%</span></span>
      <span>📊 <strong>RAM:</strong> <span style="color: %s">%d%%</span></span>
      <span style="float:right">Running on OCaml 5.x</span>
    </div>
    |}
       uptime_str cpu_color cpu_usage ram_color ram_usage)

let projects_view _req =
  let username = "AbdellahBouarguan" in
  let%lwt all_repos = Github.fetch_repos_cached username in

  (* FILTERING APPLIED HERE *)
  (* If filtered list is empty, we show all repos as a fallback,
     otherwise we show only the featured ones. *)
  let featured = Github.filter_featured all_repos in
  let repos_to_show = if featured = [] then all_repos else featured in

  let list_html =
    match repos_to_show with
    | [] ->
        "<p>No repositories found. (Add 'portfolio-featured' topic to your \
         GitHub repos to see them here!)</p>"
    | _ -> String.concat "\n" (List.map render_repo repos_to_show)
  in
  Dream.html list_html

let skills_view _req =
  let skills_html = String.concat "\n" (List.map render_skill my_skills) in
  Dream.html
    (Format.sprintf
       {| <article><header><strong>Technical Expertise</strong></header>%s</article> |}
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

(* --- THE QUINE: SOURCE CODE VIEW --- *)
let source_code_view _req =
  (* Reads its own source file! *)
  let%lwt content = Lwt_io.(with_file ~mode:Input "lib/handlers.ml" read) in
  Dream.html
    (Format.sprintf
       {|
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Source Code | OCaml Portfolio</title>
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css">
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism-tomorrow.min.css">
      <style>
        body { background-color: #0f172a; color: #e2e8f0; }
        pre { border: 1px solid #334155; }
      </style>
    </head>
    <body>
      <main class="container">
        <hgroup>
          <h1>Source Code</h1>
          <h2>lib/handlers.ml</h2>
        </hgroup>
        <a href="/" role="button" class="secondary outline">← Back to Portfolio</a>
        <pre><code class="language-ocaml">%s</code></pre>
      </main>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/prism.min.js"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-ocaml.min.js"></script>
    </body>
    </html>
    |}
       (Dream.html_escape content))

let home_template =
  {|
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>CS Portfolio</title>
    <link rel="stylesheet" href="/static/style.css">
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
          <li><a href="#" hx-get="/projects" hx-target="#content" hx-indicator="#loading">Projects</a></li>
          <li><a href="#" hx-get="/skills" hx-target="#content">Skills</a></li>
          <li><a href="/source" target="_blank"><strong>View Source</strong></a></li> <li><a href="#" hx-get="/contact" hx-target="#content">Contact</a></li>
        </ul>
      </nav>
      <div id="loading" class="htmx-indicator">
        <article aria-busy="true">Fetching data from GitHub API...</article>
      </div>
      <div id="content" style="min-height: 200px">
        <p>Welcome. Select a tab to view content.</p>
      </div>
      <footer hx-get="/status" hx-trigger="load, every 2s" hx-swap="innerHTML">
        Loading System Status...
      </footer>
    </main>
  </body>
  </html>
  |}

let home_view _req = Dream.html home_template
