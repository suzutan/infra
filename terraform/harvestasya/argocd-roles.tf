
locals {
  role_argocd_admin = [
    "suzutan",
  ]
}

resource "github_team" "argocd_admin" {
  name                      = "argocd-admin"
  description               = "adgocd admin access"
  privacy                   = "secret"
  create_default_maintainer = false
}

resource "github_team_membership" "argocd_admin" {
  for_each = toset(local.role_argocd_admin)
  team_id  = github_team.argocd_admin.id
  username = each.value
  role     = "maintainer"
}
