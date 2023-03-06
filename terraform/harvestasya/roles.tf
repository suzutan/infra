
locals {
  org_owners = [
    "suzutan",
  ]
  role_admin = [
    "suzutan",
  ]
  all_users = setunion(
    local.role_admin,
  )


}

# owner
resource "github_membership" "owner" {
  for_each = toset(local.org_owners)
  username = each.value
  role     = "admin"
}

# member
resource "github_membership" "member" {
  for_each = toset([for i in local.all_users : i if !contains(local.org_owners, i)])
  username = each.value
  role     = "member"
}

resource "github_team" "role_members" {
  name                      = "members"
  description               = "all members"
  privacy                   = "secret"
  create_default_maintainer = false
}

resource "github_team_membership" "members" {
  for_each = toset(local.all_users)
  team_id  = github_team.role_members.id
  username = each.value
  role     = contains(local.org_owners, each.value) ? "maintainer" : "member"
}



resource "github_team" "role_admin" {
  name                      = "admin"
  description               = "admin"
  privacy                   = "secret"
  create_default_maintainer = false
}

resource "github_team_membership" "role_admin" {
  for_each = toset(local.role_admin)
  team_id  = github_team.role_admin.id
  username = each.value
  role     = "maintainer"
}
