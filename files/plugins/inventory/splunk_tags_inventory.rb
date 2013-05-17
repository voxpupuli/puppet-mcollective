# Generates an inventory in Splunk's tags.conf format, aka Python configparser format
# See http://docs.puppetlabs.com/mcollective/reference/ui/nodereports.html#printf-style-reports
inventory do
  format "# %s\n[host=%s]\n%s = enabled\n%s = enabled\n%s = enabled\n%s = enabled\n\n\n\n"
  fields { [ identity, facts["hostname"], facts["serverenv"], facts["serverrole"], facts["servertype"], facts["location"] ] }
end
