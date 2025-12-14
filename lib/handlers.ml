let home_template = 
  {|
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CS Portfolio | OCaml</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css">
    <script src="https://unpkg.com/htmx.org@1.9.6"></script>
    <style>
       /* Custom tweaks */
       nav { border-bottom: 1px solid #333; padding-bottom: 1rem; margin-bottom: 2rem; }
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
          <li><a href="#" hx-get="/projects" hx-target="#content">Projects</a></li>
          <li><a href="#" hx-get="/skills" hx-target="#content">Skills</a></li>
          <li><a href="#" hx-get="/contact" hx-target="#content">Contact</a></li>
        </ul>
      </nav>

      <div id="content">
        <p>Welcome. This site is served by an OCaml Dream server on Localhost.</p>
      </div>
    </main>
  </body>
  </html>
  |}

let projects_view _req =
  Dream.html 
  {|
  <article>
    <header><strong>Portfolio Website</strong></header>
    <p>Built with OCaml, Dream, and HTMX. No React, no bloat.</p>
    <footer><a href="https://github.com/" target="_blank">Source Code</a></footer>
  </article>
  <article>
    <header><strong>System Monitor</strong></header>
    <p>C++ tool to read /proc filesystem on Linux.</p>
  </article>
  |}

let skills_view _req =
  Dream.html 
  {|
  <article>
    <h3>Technical Arsenal</h3>
    <ul>
      <li><strong>Languages:</strong> C, C++, OCaml, Python</li>
      <li><strong>Systems:</strong> Linux (Manjaro), Bash, Git</li>
      <li><strong>Security:</strong> Network Analysis, CTF</li>
    </ul>
  </article>
  |}

let contact_view _req =
  Dream.html 
  {|
  <article>
    <h3>Hire Me</h3>
    <ul>
      <li><a href="https://linkedin.com">LinkedIn</a></li>
      <li><a href="https://upwork.com">Upwork</a></li>
      <li><a href="https://github.com">GitHub</a></li>
    </ul>
  </article>
  |}

let home_view _req = Dream.html home_template
