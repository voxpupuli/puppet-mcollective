# Define - mcollective::common::setting
define mcollective::common::setting($value, $setting = $name, $order = '10') {
  mcollective::setting { "mcollective::common::setting ${setting}":
    setting => $setting,
    value   => $value,
    target  => [ 'mcollective::server', 'mcollective::client' ],
    order   => '50',
  }
}
