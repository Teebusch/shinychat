# Hub for Events
EventManager <- R6::R6Class(
  "EventManager",

  public = list(
    initialize = function(broadcast_to_console = FALSE) {
      private$broadcast_to_console = broadcast_to_console
    },

    subscribe = function(type, listener) {
      private$listeners <- private$listeners |>
        tibble::add_row(type = type, listener = list(listener))

      unsub_fun <- \() self$unsubscribe(type, listener)
      invisible(unsub_fun)
    },

    unsubscribe = function(type, listener) {
      private$listeners <- private$listeners |>
        dplyr::filter(type != .env$type) |>
        dplyr::filter(!identical(listener, .env$listener))

      invisible(self)
    },

    broadcast = function(event) {
      if (private$broadcast_to_console) {
        print(event)
      }

      private$listeners |>
        dplyr::filter(type == event$type) |>
        dplyr::pull("listener") |>
        purrr::walk(\(x) x$notify(event))

      invisible(self)
    },

    get_listeners = function() {
      private$listeners
    }
  ),

  private = list(
    broadcast_to_console = NULL,
    listeners = tibble::tibble(
      type = NA_character_,
      listener = list()
    )
  )
)


# Individual event
Event <- function(type, data) {
  structure(
    class = "Event",
    .Data = list(
      id = get_uid(),
      type = type,
      timestamp = Sys.time(),
      data = data
    )
  )
}


as.list.Event <- function(x, ...) {
  res <- list(id = x$id, type = x$type, timestamp = x$timestamp)
  res <- append(res, x$data)
}


# Generic for Printing an event
print.Event <- function(x, ...) {
  sprintf("Event of type '%s'\n", x$type) |>
    cat()

  data <- as.list(x)
  paste(names(data), data) |>
    cat()
}


# Log / history of events
EventLog <- R6::R6Class(
  "EventLog",

  public = list(
    add = function(event) {
      new_entry <- tibble::tibble_row(
        type = event$type,
        timestamp = Sys.time(),
        event = event
      )

      private$logged_events <- private$logged_events |>
        dplyr::bind_rows(new_entry)

      invisible(self)
    },

    get_events = function(max_n = Inf) {
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
        private$event_log$add(event)
      }
      invisible(self)
    }
  ),

  private = list(
    event_log = NULL
  )
)
