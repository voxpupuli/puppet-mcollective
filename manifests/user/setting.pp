# Define - mcollective::user::setting
define mcollective::user::setting($username, $setting, $value, $order = '70') {
  mcollective::setting { "mcollective::user::setting ${title}":
    setting => $setting,
    value   => $value,
    target  => "mcollective::user ${username}",
    order   => $order,
  }
}
