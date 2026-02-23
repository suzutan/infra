resource "github_membership" "this" {
  for_each = local.org_members

  username = each.key
  role     = each.value.role
}
