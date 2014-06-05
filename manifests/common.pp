#
class mcollective::common {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  contain mcollective::common::config
}
