##[>] 🤖🤖
output "group_ids" {
  value = { for k, v in gitlab_group.this : k => v.id }
}
##[<] 🤖🤖

##[>] 🤖🤖
output "project_ids" {
  value = { for k, v in gitlab_project.this : k => v.id }
}
##[<] 🤖🤖
