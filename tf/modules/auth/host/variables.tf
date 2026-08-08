##[>] 🤖🤖
variable "user_ssh_keys" {
  type = map(object({
    key        = string
    usage_type = optional(string, "auth")
  }))
  default = {}
}
##[<] 🤖🤖
