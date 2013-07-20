# Generates an inventory in CSV format
# See http://docs.puppetlabs.com/mcollective/reference/ui/nodereports.html#printf-style-reports
# and http://splunk-base.splunk.com/answers/67978/how-can-i-set-up-a-case-insensitive-lookup-instead-of-tags
# for why we might want this.
inventory do
  format "%s,%s,%s,%s,%s,%s\n"
  fields { [ facts["hostname"], identity, facts["serverenv"], facts["serverrole"], facts["servertype"], facts["location"] ] }
end
