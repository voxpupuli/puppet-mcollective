# Define - mcollective::server::setting
define mcollective::server::setting (
  $value,
  $setting = $name,
  $order   = '30',
) {
  mcollective::setting { "mcollective::server::setting ${title}":
    setting => $setting,
    value   => $value,
    target  => 'mcollective::server',
    order   => $order,
  }
}
