# private define - mcollective::secret_file
#
# wrapper around 'file' resource that sets show_diff to
# false when running on puppet 3.2+ and is_secret is true.

define mcollective::secret_file(
  $owner     = undef,
  $group     = undef,
  $mode      = undef,
  $source    = undef,
  $content   = undef,
  $is_secret = true,
) {
  if $is_secret and versioncmp($settings::puppetversion, '3.2.0') >= 0 {
    File { show_diff => false }
  }

  file { $title:
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    source  => $source,
    content => $content,
  }
}
