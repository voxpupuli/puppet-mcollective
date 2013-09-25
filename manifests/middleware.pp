# Private class
class mcollective::middleware {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  anchor { 'mcollective::middleware::begin': }
  anchor { 'mcollective::middleware::end': }

  mcollective::soft_include { "::mcollective::middleware::${mcollective::connector}":
    start => Anchor['mcollective::middleware::begin'],
    end   => Anchor['mcollective::middleware::end'],
  }
}
