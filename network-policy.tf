resource "snowflake_network_policy" "privatelink" {
  count   = length(var.snowflake_allowed_ip_list) > 0 ? 1 : 0
  name    = "PRIVATELINK"
  comment = var.comment

  allowed_ip_list = var.snowflake_allowed_ip_list
}


/*

resource "snowflake_network_policy_attachment" "privatelink" {
  count               = length(var.snowflake_allowed_ip_list) > 0 ? 1 : 0
  network_policy_name = snowflake_network_policy.privatelink[0].name
  set_for_account     = true
}

*/
