# private define - mcollective::setting
define mcollective::setting($setting, $value, $target, $order = '50') {
  # The parser chokes on `data => { $setting => $value }` so help it out
  $data = {}
  $data[$setting] = $value
  datacat_fragment { "mcollective::setting ${title}":
    target => $target,
    order  => $order,
    data   => $data,
  }
}
