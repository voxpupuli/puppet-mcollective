# Define - mcollective::common::setting
define mcollective::common::setting($setting = $name, $value, $order = '10') {
  mcollective::setting { "mcollective::common::setting ${setting}":
    setting => $setting,
    value   => $value,
    target  => [ 'mcollective::server', 'mcollective::client' ],
    order   => '50',
  }
}
