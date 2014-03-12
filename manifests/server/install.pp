# private class
class mcollective::server::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::manage_packages {
    package { 'mcollective': ensure => $mcollective::version, }

    $ruby_stomp_package = undef

    case $::osfamily {
      'Debian' : { $ruby_stomp_package = 'ruby-stomp' }
      'Redhat' : { $ruby_stomp_package = 'rubygem-stomp' }
    }

    if $ruby_stomp_package {
      package { $ruby_stomp_package:
        ensure => $mcollective::ruby_stomp_ensure,
        before => Package['mcollective'],
      }
    }
  }
}
