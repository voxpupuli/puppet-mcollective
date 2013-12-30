# private class
class mcollective::agents {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  anchor { 'mcollective::agents::begin': } ->
  class { '::mcollective::agents::install': } ->
  anchor { 'mcollective::agents::end': }
}
