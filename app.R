options(shiny.autoreload = TRUE)

# Exists globally for all users/sessions on server
chat_room <- ChatRoom$new()
avatar_cache <- AvatarCache$new()

# do this once to setup:
#file.copy(
#  from = system.file(package = "shiny", "www/shared/shiny.js"),
#  to = "src/shiny.js"
#)
#file.copy(
#  from = system.file(package = "shiny", "www/shared/jquery.js"),
#  to = "www/jquery.js"
#)

ui <- function(req) {
  path <- stringr::str_split_1(req$PATH_INFO, "\\/")

  if (path[2] == "avatar") {
    avatar_id <- path[3] %||% ""
    avatar <- avatar_cache$get(avatar_id)

    res <- shiny::httpResponse(
      status = 200L,
      content_type = "image/svg+xml",
      content = avatar
    )
  } else {
    res <- shiny::httpResponse(
      status = 200L,
      content_type = "text/html",
      content = readr::read_file("www/index.html")
    )
  }

  return(res)
}


# Exists for each individual user/session
session_server <- function(input, output, session) {
  user <- ChatUser$new()
  chat_room$add_user(user)

  view_model <- ViewModel$new(
    input = input,
    output = output,
    session = session,
    room = chat_room,
    user = user
  )
}


# run server
shiny::shinyApp(ui, session_server, uiPattern = ".*")
