locals {
  org_members = {
    suzutan = {
      role = "admin"
    }
  }

  teams = {
    admin = {
      description = "Organization administrators"
      privacy     = "closed"
    }
  }

  team_memberships = {
    "admin:suzutan" = {
      team_slug = "admin"
      username  = "suzutan"
      role      = "maintainer"
    }
  }
}
