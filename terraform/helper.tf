locals {
  env_backend = [
    for line in split("\n", file(var.env_file_backend)) :
    trimspace(line)
    if length(trimspace(line)) > 0 && !startswith(trimspace(line), "#")
  ]

  env_database = [
    for line in split("\n", file(var.env_file_database)) :
    trimspace(line)
    if length(trimspace(line)) > 0 && !startswith(trimspace(line), "#")
  ]

  env_frontend = [
    for line in split("\n", file(var.env_file_frontend)) :
    trimspace(line)
    if length(trimspace(line)) > 0 && !startswith(trimspace(line), "#")
  ]
}
