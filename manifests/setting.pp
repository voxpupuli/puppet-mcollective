# private define - mcollective::setting
define mcollective::setting($setting, $value, $target, $order = '50') {
  datacat_fragment { "mcollective::setting ${title}":
    target => $target,
    order  => $order,
    data   => hash([ $setting, $value ]),
  }
}
