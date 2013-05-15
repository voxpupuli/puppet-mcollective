module MCollective
  module Agent
    class Nettest<RPC::Agent
      activate_when do
        begin
          require 'net/ping/icmp'
          require 'mcollective/util/nettest_agent'

          true
        rescue LoadError => e
          Log.warn('Cannot load Nettest_agent plugin. Nettest_agent plugin requires the net/ping gem and util/nettest_agent class to run.')

          false
        end
      end

      action "ping" do
        if ipaddr = Util::NettestAgent.get_ip_from_hostname(request[:fqdn])
          reply[:rtt] = Nettest.testping(ipaddr)
          reply.fail!('Cannot reach host') unless reply[:rtt]
        else
          reply.fail!('Cannot resolve hostname')
        end
      end

      action "connect" do
        if ipaddr = Util::NettestAgent.get_ip_from_hostname(request[:fqdn])
          reply[:connect], reply[:connect_status], reply[:connect_time] = Nettest.testconnect(ipaddr, request[:port])
        else
          reply.fail!('Cannot resolve hostname')
        end
      end

      # Does the actual work of the ping action
      def self.testping(ipaddr)
        icmp = Net::Ping::ICMP.new(ipaddr)

        if icmp.ping?
          return (icmp.duration * 1000)
        else
          return nil
        end
      end

      # Does the actual work of the connect action
      # #testconnet will try and make a connection to a
      # given ip address, returning the time it took to
      # establish the connection, the connection status
      # and a boolean value stating if the connection could
      # be made.
      def self.testconnect(ipaddr, port)
        connected = false
        connect_string = nil
        connect_time = nil

        begin
          Timeout.timeout(2) do
            begin
              time = Time.now
              t = TCPSocket.new(ipaddr, port)
              t.close
              connect_time = Time.now - time
              connected = true
              connect_string =  'Connected'
            rescue
              connect_string = 'Connection Refused'
            end
          end
        rescue Timeout::Error
          connect_string =  'Connection Timeout'
        end

        return connected, connect_string, connect_time
      end
    end
  end
end
