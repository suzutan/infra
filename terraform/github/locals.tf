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
      members = {
        suzutan = "maintainer"
      }
    }
  }

  # Flatten team members into a map for github_team_membership resource
  team_memberships = merge([
    for team_name, team in local.teams : {
      for username, role in team.members :
      "${team_name}:${username}" => {
        team_slug = team_name
        username  = username
        role      = role
      }
    }
  ]...)
}
