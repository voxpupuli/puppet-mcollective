#
class mcollective::common {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  anchor { 'mcollective::common::begin': } ->
  class { '::mcollective::common::config': } ->
  anchor { 'mcollective::common::end': }
}
