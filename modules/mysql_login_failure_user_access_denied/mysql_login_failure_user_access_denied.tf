resource "shoreline_notebook" "mysql_login_failure_user_access_denied" {
  name       = "mysql_login_failure_user_access_denied"
  data       = file("${path.module}/data/mysql_login_failure_user_access_denied.json")
  depends_on = [shoreline_action.invoke_pass_reset_script,shoreline_action.invoke_script_grant_mysql_permissions]
}

resource "shoreline_file" "pass_reset_script" {
  name             = "pass_reset_script"
  input_file       = "${path.module}/data/pass_reset_script.sh"
  md5              = filemd5("${path.module}/data/pass_reset_script.sh")
  description      = "Check the user's login credentials to ensure that they are correct and have not been changed. If necessary, reset the user's password to ensure that they are using the correct login details."
  destination_path = "/tmp/pass_reset_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "script_grant_mysql_permissions" {
  name             = "script_grant_mysql_permissions"
  input_file       = "${path.module}/data/script_grant_mysql_permissions.sh"
  md5              = filemd5("${path.module}/data/script_grant_mysql_permissions.sh")
  description      = "If necessary, grant additional permissions to the user to ensure that they have permissions to access the MySQL server."
  destination_path = "/tmp/script_grant_mysql_permissions.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_pass_reset_script" {
  name        = "invoke_pass_reset_script"
  description = "Check the user's login credentials to ensure that they are correct and have not been changed. If necessary, reset the user's password to ensure that they are using the correct login details."
  command     = "`chmod +x /tmp/pass_reset_script.sh && /tmp/pass_reset_script.sh`"
  params      = ["MYSQL_ADMIN","MYSQL_HOST","MYSQL_ADMIN_PASSWORD","MYSQL_USER","MYSQL_USER_PASSWORD"]
  file_deps   = ["pass_reset_script"]
  enabled     = true
  depends_on  = [shoreline_file.pass_reset_script]
}

resource "shoreline_action" "invoke_script_grant_mysql_permissions" {
  name        = "invoke_script_grant_mysql_permissions"
  description = "If necessary, grant additional permissions to the user to ensure that they have permissions to access the MySQL server."
  command     = "`chmod +x /tmp/script_grant_mysql_permissions.sh && /tmp/script_grant_mysql_permissions.sh`"
  params      = ["MYSQL_POD_NAME","MYSQL_ADMIN","MYSQL_ADMIN_PASSWORD","MYSQL_USER"]
  file_deps   = ["script_grant_mysql_permissions"]
  enabled     = true
  depends_on  = [shoreline_file.script_grant_mysql_permissions]
}

