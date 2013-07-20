metadata :name => "process_data",
         :description => "Checks if a process matching a supplied pattern is present",
         :author => "Pieter Loubser <pieter.loubser@puppetlabs.com>",
         :license => "ASL 2.0",
         :version => "1.0.0",
         :url => "http://puppetlabs.com",
         :timeout => 1

dataquery :description => "Process" do
  input :query,
        :prompt => "Pattern matching process names",
        :description => "The Pattern matching process names",
        :type => :string,
        :validation => :string,
        :maxlength => 50

  output :exists,
         :description => "Matches if there exists a process matching the query pattern",
         :display_as => "Exists?"
end
