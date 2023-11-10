
locals {
  org_owners = [
    "suzutan",
  ]
  all_users = setunion(
    local.role_argocd_admin,
    local.role_asf_users,
    local.role_grafana_admin_users,
    local.role_grafana_editor_users,
    local.role_grafana_viewer_users,
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
