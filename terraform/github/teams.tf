resource "github_team" "this" {
  for_each = local.teams

  name        = each.key
  description = each.value.description
  privacy     = each.value.privacy
}

resource "github_team_membership" "this" {
  for_each = local.team_memberships

  team_id  = github_team.this[each.value.team_slug].id
  username = each.value.username
  role     = each.value.role
}
