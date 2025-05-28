ViewModel <- R6::R6Class(
  "ViewModel",

  public = list(
    initialize = function(
      input,
      output,
      session,
      room,
      user
    ) {
      private$input <- input
      private$output <- output
      private$session <- session
      private$user <- user
      private$room <- room

      private$set_this_user_info()

      # initial render
      private$update_user_list()
      private$update_room_history()

      # then listen for events and user inputs
      private$observe_user_inputs()
      private$observe_room_events()

      invisible(self)
    }
  ),

  private = list(
    input = NULL,
    output = NULL,
    session = NULL,
    user = NULL,
    room = NULL,
    unsubscribe_from_room = NULL,

    # send general user info to frontend
    set_this_user_info = function() {
      user_info = list(
        user_uid = private$user$get_uid(),
        username = private$user$get_name()
      )
      private$session$sendCustomMessage("set-this-user-info", user_info)
    },

    # redraw user list
    update_user_list = function() {
      users_in_room <- private$room$get_user_list()

      user_list <- users_in_room |>
        purrr::map(\(user) {
          list(
            name = user$get_name(),
            uid = user$get_uid(),
            last_seen = user$get_last_active()
          )
        })

      private$session$sendCustomMessage("update-user-list", user_list)
    },

    # redraw room history (replaces all contents in chat window)
    update_room_history = function() {
      history <- private$room$get_history()
      events <- purrr::map(history$event, \(event) as.list(event))

      private$session$sendCustomMessage("update-room-history", events)
    },

    # watch for inputs from this user
    observe_user_inputs = function() {
      # this user sends message
      observeEvent(private$input$send_chat_message, {
        message <- private$input$send_chat_message |>
          as.character() |>
          stringr::str_trim()

        private$user$say(message)
      })

      # this user closes or refreshes the browser window
      observeEvent(private$input$user_logout, {
        message <- private$input$user_logout
        private$room$remove_user(private$user)
      })

      # this user ends session
      shiny::onSessionEnded(
        session = private$session,
        \() private$room$remove_user(private$user)
      )
    },

    # watch for any events from the room
    observe_room_events = function() {
      # forward events to client
      forward_event_subscriber <- CallbackEventSubscriber$new(\(event) {
        private$forward_event_to_client(event)
        private$update_user_list()
      })

      unsubscribe_funs <- list(
        private$room$subscribe_to_events(
          "chat-message",
          forward_event_subscriber
        ),
        private$room$subscribe_to_events(
          "user-added",
          forward_event_subscriber
        ),
        private$room$subscribe_to_events(
          "user-removed",
          forward_event_subscriber
        )
      )

      # store a function to unsubscribe
      unsubscribe_fun <- \() lapply(unsubscribe_funs, rlang::exec)
      private$unsubscribe_from_room <- unsubscribe_fun
      invisible(unsubscribe_fun)
    },

    unobserve_room_events = function() {
      private$unsubscribe_from_room()
    },

    forward_event_to_client = function(event) {
      private$session$sendCustomMessage(event$event_type, as.list(event))
    }
  )
)


chat_ui <- function() {
  bslib::page_sidebar(
    window_title = "Shiny Chat",
    lang = "en",
    fillable = TRUE,
    fillable_mobile = TRUE,

    theme = bslib::bs_theme(
      primary = "#4F6E58"
    ),

    # dependencies
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "main.css"),
      tags$script(src = "main.js")
    ),

    # sidebar with user list
    sidebar = bslib::sidebar(
      width = 400L,
      bg = "#E4E2E0",
      open = "desktop",

      tags$div(
        tags$h5("Active Users", tags$span(class = "n-active")),
        tags$div(id = "user-list")
      )
    ),

    # chat window
    tags$div(
      id = "chat",
      class = "container-md",
      tags$div(
        id = "messages"
      ),
      tags$div(
        id = "message-editor",
        tags$textarea(
          id = "new-message-text",
          placeholder = "Message",
          autofocus = NA,
          minlength = 1L
        )
      )
    )
  )
}


AvatarCache = R6::R6Class(
  "AvatarCache",

  public = list(
    # get avatar for id. If not in cache, create a new one
    get = function(id) {
      avatar <- private$cache[[id]]
      if (is.null(avatar)) {
        avatar <- private$create(id)
      }
      return(avatar)
    }
  ),

  private = list(
    cache = list(),

    create = function(id) {
      req <- httr2::request(
        "https://api.dicebear.com/9.x/bottts-neutral/svg"
      ) |>
        httr2::req_url_query(
          size = 60L,
          radius = 10L,
          seed = URLencode(id)
        )

      resp <- httr2::req_perform(req)

      # TODO: handle http errors
      avatar <- httr2::resp_body_string(resp)

      private$cache[id] <- avatar
    }
  )
)
