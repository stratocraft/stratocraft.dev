terraform {
  cloud {
    organization = "stratocraft"

    workspaces {
      name = "stratocraft-dev"
    }
  }
}