# Private class
class mcollective::common::config::securityprovider::none {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  mcollective::plugin { 'securityprovider/none': }
}
