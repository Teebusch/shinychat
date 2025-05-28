make_random_username <- function() {
  ids::adjective_animal(style = "title")
}


get_uid <- function() {
  ids::uuid(drop_hyphens = TRUE)
}
