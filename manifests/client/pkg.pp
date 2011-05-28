class mcollective::client::pkg(
  $version,
  $pkg_provider
) {

  #include 'mcollective::pkg'

  package { 'mcollective-client':
    ensure	  => $version,
    provider  => $pkg_provider,
  }
}
