ChatRoom <- R6::R6Class(
  "ChatRoom",

  public = list(
    initialize = function(name) {
      private$users <- UserList$new()
      private$events <- EventManager$new()
      private$history <- EventLog$new()

      # log all room-events to history
      logging_event_subscriber <- LoggingEventSubscriber$new(
        event_log = private$history
      )

      private$events$subscribe("chat-message", logging_event_subscriber)
      private$events$subscribe("user-added", logging_event_subscriber)
      private$events$subscribe("user-removed", logging_event_subscriber)

      invisible(self)
    },

    add_chat_message = function(chat_message) {
      private$events$broadcast(Event("chat-message", chat_message))
      invisible(self)
    },

    add_user = function(user) {
      private$users$add(user)
      user$set_room(self)
      private$events$broadcast(Event("user-added", user))

      invisible(self)
    },

    remove_user = function(user) {
      private$users$remove(user)
      user$set_room(NULL)
      private$events$broadcast(Event("user-removed", user))

      invisible(self)
    },

    get_user_list = function() {
      private$users$get_all()
    },

    subscribe_to_events = function(event_type, listener) {
      private$events$subscribe(event_type, listener)
    },

    unsubscribe_from_events = function(event_type, listener) {
      private$events$unsubscribe(event_type, listener)
    },

    get_history = function(max_n = Inf) {
      private$history$get_logged_events(max_n)
    }
  ),

  private = list(
    name = NA_character_,
    events = NULL,
    users = NULL,
    history = NULL
  )
)


ChatUser <- R6::R6Class(
  "ChatUser",

  public = list(
    initialize = function(name = NULL) {
      private$uid <- get_uid()
      private$name <- name %||% make_random_username()

      self$register_activity()
    },

    get_uid = function() {
      private$uid
    },

    get_name = function() {
      private$name
    },

    get_room = function() {
      private$room
    },

    set_room = function(room) {
      private$room <- room
      invisible(self)
    },

    say = function(content) {
      if (!is.null(private$room) && nchar(content) > 0) {
        chat_message = ChatMessage(
          author_uid = private$uid,
          author_name = private$name,
          content = content
        )
        private$room$add_chat_message(chat_message)
      }

      self$register_activity()

      invisible(self)
    },

    get_last_active = function() {
      private$last_active
    },

    register_activity = function() {
      private$last_active <- Sys.time()
    }
  ),

  private = list(
    uid = NULL,
    name = NULL,
    avatar = NULL,
    room = NULL,
    last_active = NULL
  )
)


ChatMessage <- function(
  author_uid = NA_character_,
  author_name = NA_character_,
  content = NA_character_
) {
  structure(
    class = "ChatMessage",
    .Data = list(
      message_uid = get_uid(),
      time_sent = Sys.time(),
      author_uid = author_uid,
      author_name = author_name,
      content = content
    )
  )
}


UserList <- R6::R6Class(
  "UserList",

  public = list(
    add = function(user) {
      if (!self$has(user)) {
        private$users <- append(private$users, list(user))
      }
      invisible(self)
    },

    remove = function(user) {
      if (self$has(user)) {
        private$users <- private$users |>
          purrr::discard(\(x) identical(x, user))
      }
      invisible(self)
    },

    has = function(user) {
      purrr::some(private$users, \(x) identical(x, user))
    },

    get_all = function() {
      private$users
    }
  ),

  private = list(
    users = list()
  )
)
