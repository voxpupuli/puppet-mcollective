Facter.add('mco_version') do
  setcode do
    begin
      require 'mcollective'
      MCollective::VERSION
    rescue LoadError
      nil
    end
  end
end
