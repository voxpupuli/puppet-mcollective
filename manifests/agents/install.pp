# private class
class mcollective::agents::install {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $mcollective::agents {
  	package {'mcollective-package-agent':
  		ensure => latest,
  	}
  }
}
