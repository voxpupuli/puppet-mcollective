require 'spec_helper_system'

describe 'single node setup:' do
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  pp = IO.read(proj_root + '/spec/fixtures/manifests/end_to_end.pp')

  context puppet_apply(pp) do
    its(:exit_code) { is_expected.not_to eq(1) }
  end

  describe 'bounce rabbitmq maybe' do
    # rabbitmq needs a bounce to enable stomp - the rabbitmq module
    # should probably take care of this
    context shell('sudo service rabbitmq-server restart') do
      # we want the command to run, we don't care what it returns
      its(:exit_code) { is_expected.to be_a_kind_of(Numeric) }
    end
  end

  describe 'root can do what they like' do
    context shell('sudo -i mco ping') do
      its(:stdout) { is_expected.to =~ %r{.foo.vm} }
    end

    context shell('sudo -i mco rpc rpcutil inventory -j </dev/null') do
      its(:stdout) { is_expected.to =~ %r{discovery} }
    end

    context shell('sudo -i mco rpc nrpe runcommand command=hello_world -j </dev/null') do
      its(:stdout) { is_expected.to =~ %r{Hello World!} }
    end
  end

  describe 'nagios user can do limited things' do
    context shell('sudo -i -u nagios mco ping') do
      its(:stdout) { is_expected.to =~ %r{.foo.vm} }
    end

    context shell('sudo -i -u nagios mco rpc rpcutil inventory -j </dev/null') do
      its(:stdout) { is_expected.to =~ %r{You are not authorized to call this agent or action} }
    end

    context shell('sudo -i -u nagios mco rpc nrpe runcommand command=hello_world -j </dev/null') do
      its(:stdout) { is_expected.to =~ %r{Hello World!} }
    end
  end
end
