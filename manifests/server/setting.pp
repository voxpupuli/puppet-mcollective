# Define - mcollective::server::setting
define mcollective::server::setting($setting = $name, $value, $order = '30') {
  mcollective::setting { "mcollective::server::setting ${title}":
    setting => $setting,
    value   => $value,
    target  => [ 'mcollective::server' ],
    order   => $order,
  }
}
