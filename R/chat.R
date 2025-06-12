ChatRoom <- R6::R6Class(
  "ChatRoom",

  public = list(
    initialize = function(name) {
      private$users <- UserList$new()
      private$events <- EventManager$new(broadcast_to_console = TRUE)

      # log all room-events to history
      private$history <- EventLog$new()
      logger <- LoggingEventSubscriber$new(event_log = private$history)

      private$events$subscribe("chat-message", logger)
      private$events$subscribe("user-joined", logger)
      private$events$subscribe("user-left", logger)

      invisible(self)
    },

    add_message = function(user, message) {
      event <- Event(
        type = "chat-message",
        data = ChatMessage(userId = user$get_id(), message = message)
      )
      private$events$broadcast(event)
      invisible(self)
    },

    add_user = function(user) {
      private$users$add(user)
      user$set_room(self)
      event <- Event(
        type = "user-joined",
        data = list(userId = user$get_id())
      )
      private$events$broadcast(event)
      invisible(self)
    },

    remove_user = function(user) {
      private$users$remove(user)
      user$set_room(NULL)
      event <- Event(
        type = "user-left",
        data = list(userId = user$get_id())
      )
      private$events$broadcast(event)
      invisible(self)
    },

    get_users = function() {
      private$users$get_all()
    },

    subscribe_to_events = function(type, listener) {
      private$events$subscribe(type, listener)
    },

    unsubscribe_from_events = function(type, listener) {
      private$events$unsubscribe(type, listener)
    },

    get_history = function(max_n = Inf) {
      private$history$get_events(max_n)
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
      private$id <- get_uid()
      private$name <- name %||% make_random_username()
      self$update_last_seen()
    },

    get_id = function() {
      private$id
    },

    get_name = function() {
      private$name
    },

    get_room = function() {
      private$room
    },

    set_room = function(room) {
      private$room <- room
      self$update_last_seen()
      invisible(self)
    },

    say = function(message) {
      if (!is.null(private$room) && nchar(message) > 0) {
        private$room$add_message(user = self, message = message)
      }

      self$update_last_seen()
      invisible(self)
    },

    get_last_seen = function() {
      private$last_seen
    },

    update_last_seen = function() {
      private$last_seen <- Sys.time()
    }
  ),

  private = list(
    id = NULL,
    name = NULL,
    room = NULL,
    last_seen = NULL
  )
)


ChatMessage <- function(userId, message) {
  structure(
    class = "ChatMessage",
    .Data = list(
      userId = userId,
      message = message
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
