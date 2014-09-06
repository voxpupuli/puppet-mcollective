# Define - mcollective::common::setting
define mcollective::common::setting($setting = $name, $value, $order = '50') {
  mcollective::setting { "mcollective::common::setting ${name}":
    setting => $setting,
    value   => $value,
    target  => [ 'mcollective::server', 'mcollective::client' ],
    order   => $order,
  }
}
