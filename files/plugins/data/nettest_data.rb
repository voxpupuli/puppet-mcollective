module MCollective
  module Data
    class Nettest_data<Base
      activate_when { PluginManager['nettest_agent'] }

      query do |params|
        host, port = params.split(':')
        connected, _, _ = Agent::Nettest.testconnect(host, port)

        result[:connect] = connected
      end
    end
  end
end
