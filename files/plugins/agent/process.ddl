metadata    :name        => "process",
            :description => "Agent To Manage Processes",
            :author      => "R.I.Pienaar",
            :license     => "ASL 2.0",
            :version     => "3.0.0",
            :url         => "http://projects.puppetlabs.com/projects/mcollective-plugins/wiki",
            :timeout     => 10

requires :mcollective => '2.2.1'

action "list", :description => "List Processes" do
    input :pattern,
          :prompt      => "Pattern to match",
          :description => "List only processes matching this patten",
          :type        => :string,
          :validation  => :shellsafe,
          :optional    => true,
          :maxlength    => 50

    input :just_zombies,
          :prompt      => "Zombies Only",
          :description => "Restrict the process list to Zombie Processes only",
          :type        => :boolean,
          :optional    => true

    output :pslist,
           :description => "Process List",
           :display_as => "The Process List"

    summarize do
      aggregate process_summary(:pslist)
    end
end
