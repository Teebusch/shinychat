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

      # initial render
      private$update_this_user()
      private$update_user_list()
      private$update_room_history()

      # then listen for events and user inputs
      private$observe_user_inputs()
      private$observe_room()

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
    update_this_user = function() {
      private$session$sendCustomMessage(
        "update-this-user",
        list(
          userId = private$user$get_id(),
          name = private$user$get_name()
        )
      )
    },

    # redraw user list
    update_user_list = function() {
      users <- private$room$get_users() |>
        purrr::map(\(u) {
          list(
            id = u$get_id(),
            name = u$get_name(),
            lastSeen = u$get_last_seen()
          )
        })

      private$session$sendCustomMessage(
        "update-user-list",
        users
      )
    },

    # redraw room history (replaces all contents in chat window)
    update_room_history = function() {
      history <- private$room$get_history() |>
        dplyr::arrange(timestamp) |>
        dplyr::pull(event) |>
        purrr::map(as.list)

      private$session$sendCustomMessage(
        "update-room-history",
        history
      )
    },

    forward_event_to_client = function(event) {
      private$session$sendCustomMessage(
        event$type,
        as.list(event)
      )
    },

     # watch for events from the room and forward them to the client
    observe_room = function() {
      # forward events to client
      forward_to_client <- CallbackEventSubscriber$new(\(event) {
        private$forward_event_to_client(event)
        private$update_user_list()
      })

      unsubscribe_funs <- list(
        private$room$subscribe_to_events("chat-message", forward_to_client),
        private$room$subscribe_to_events("user-joined", forward_to_client),
        private$room$subscribe_to_events("user-left", forward_to_client)
      )

      # store a function to unsubscribe
      unsubscribe_fun <- \() lapply(unsubscribe_funs, rlang::exec)
      private$unsubscribe_from_room <- unsubscribe_fun
      invisible(unsubscribe_fun)
    },

    unobserve_room = function() {
      private$unsubscribe_from_room()
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
    }
  )
)


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
