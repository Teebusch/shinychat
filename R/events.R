# Hub for Events
EventManager <- R6::R6Class(
  "EventManager",

  public = list(
    initialize = function(broadcast_to_console = FALSE) {
      private$broadcast_to_console = broadcast_to_console
    },

    subscribe = function(event_type, listener) {
      private$listeners <- private$listeners |>
        tibble::add_row(
          event_type = event_type,
          listener = list(listener)
        )

      unsubscribe_fun <- \() self$unsubscribe(event_type, listener)
      invisible(unsubscribe_fun)
    },

    unsubscribe = function(event_type, listener) {
      private$listeners <- private$listeners |>
        dplyr::filter(event_type != .env$event_type) |>
        dplyr::filter(!identical(listener, .env$listener))

      invisible(self)
    },

    broadcast = function(event) {
      if (private$broadcast_to_console) {
        print(event)
      }

      private$listeners |>
        dplyr::filter(event_type == event$event_type) |>
        dplyr::pull("listener") |>
        purrr::walk(\(x) x$notify(event))

      invisible(self)
    },

    get_listeners = function() {
      private$listeners
    }
  ),

  private = list(
    broadcast_to_console = FALSE,

    listeners = tibble::tibble(
      event_type = NA_character_,
      listener = list()
    )
  )
)


# Individual event
Event <- function(event_type, data) {
  structure(
    class = "Event",
    .Data = list(
      event_type = event_type,
      data = data
    )
  )
}


as.list.Event <- function(x, ...) {
  event_type <- x$event_type
  event_data <- x$data

  res <- list(
    event_type = event_type
  )

  if (event_type == "chat-message") {
    res <- append(res, event_data)
  }

  if (event_type %in% c("user-added", "user-removed")) {
    user <- event_data
    res$username <- user$get_name()
    res$user_uid <- user$get_uid()
  }

  return(res)
}


# Generic for Printing an event
print.Event <- function(x, ...) {
  sprintf("Event of type '%s'\n", x$event_type) |>
    cat()
}


# Log / history of events
EventLog <- R6::R6Class(
  "EventLog",

  public = list(
    log_event = function(event) {
      new_entry <- tibble::tibble_row(
        event_type = event$event_type,
        timestamp = Sys.time(),
        event = event
      )

      private$logged_events <- private$logged_events |>
        dplyr::bind_rows(new_entry)

      invisible(self)
    },

    get_logged_events = function(max_n = Inf) {
      tail(private$logged_events, max_n)
    }
  ),

  private = list(
    logged_events = NULL
  )
)


# General Purpose Event Subscriber with a callback function
CallbackEventSubscriber <- R6::R6Class(
  "CallbackEventSubscriber",

  public = list(
    initialize = function(callback) {
      private$callback <- callback
      invisible(self)
    },

    notify = function(event) {
      if (!is.null(private$callback)) {
        private$callback(event)
      }
    }
  ),

  private = list(
    callback = NULL
  )
)


# Event Subscriber for Logging / printing all observed Events
LoggingEventSubscriber <- R6::R6Class(
  "LoggingEventSubscriber",

  public = list(
    initialize = function(event_log = NULL) {
      private$event_log = event_log
      invisible(self)
    },

    notify = function(event) {
      if (!is.null(private$event_log)) {
        private$event_log$log_event(event)
      }
      invisible(self)
    }
  ),

  private = list(
    event_log = NULL,
    log_to_console = FALSE
  )
)


# Event Subscriber for showing Event Info as Toast
# - requires a Shiny session, passed via constructor
ToastEventSubscriber <- R6::R6Class(
  "ToastEventSubscriber",

  public = list(
    initialize = function(print_fun, session) {
      private$print_fun <- print_fun
      private$session <- session
      invisible(self)
    },

    notify = function(event) {
      text <- private$print_fun(event)
      shiny::showNotification(text, session = private$session)
      invisible(self)
    }
  ),

  private = list(
    print_fun = NULL,
    session = NULL
  )
)
