open Portfolio_lib

let () =
  Dream.run ~interface:"127.0.0.1" ~port:5000
    (Dream.logger
    @@ Dream.router
         [
           Dream.get "/" Handlers.home_view;
           Dream.get "/projects" Handlers.projects_view;
           Dream.get "/skills" Handlers.skills_view;
           Dream.get "/contact" Handlers.contact_view;
           Dream.get "/status" Handlers.status_view;
           Dream.get "/static/**" (Dream.static "static");
         ])
