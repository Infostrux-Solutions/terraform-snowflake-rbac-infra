output "role_names" {
  value = [
    for role in module.sf_role : role.name
  ]
}

output "parent_role_names" {
  value = [
    for role in module.parent_sf_role : role.name
  ]
}