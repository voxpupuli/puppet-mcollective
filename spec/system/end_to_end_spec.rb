require 'spec_helper_system'

describe 'single node setup:' do
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  pp = IO.read(proj_root + '/spec/fixtures/manifests/end_to_end.pp')

  context puppet_apply(pp) do
    its(:exit_code) { should_not eq(1) }
  end

  describe 'root can do what they like' do
    context shell('mco ping') do
      its(:stdout) { should =~ /main.foo.vm/ }
    end

    context shell('mco rpc rpcutil inventory -j </dev/null') do
      its(:stdout) { should =~ /discovery/ }
    end

    context shell('mco rpc nrpe runcommand command=hello_world -j </dev/null') do
      its(:stdout) { should =~ /Hello World!/ }
    end
  end

  describe 'nagios user can do limited things' do
    context shell('sudo -u nagios mco ping') do
      its(:stdout) { should =~ /main.foo.vm/ }
    end

    context shell('sudo -u nagios mco rpc rpcutil inventory -j </dev/null') do
      its(:stdout) { should =~ /You are not authorized to call this agent or action/ }
    end

    context shell('sudo -u nagios mco rpc nrpe runcommand command=hello_world -j </dev/null') do
      its(:stdout) { should =~ /Hello World!/ }
    end
  end
end
