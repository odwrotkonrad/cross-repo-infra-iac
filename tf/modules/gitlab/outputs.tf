##[>] 🤖🤖
output "group_ids" {
  value = merge(
    module.l0.group_ids,
    module.l1.group_ids,
    module.l2.group_ids,
    module.l3.group_ids,
  )
}

output "sandbox_token" {
  value     = gitlab_group_access_token.sandbox.token
  sensitive = true
}
##[<] 🤖🤖
