module MCollective
  class Application::Nettest < Application
    description "Network tests from a mcollective host"

    usage <<-END_OF_USAGE
mco nettest <ping|connect> <HOST NAME> [PORT]

The ACTION can be one of the following:

    ping    - return round-trip time between this and remote host
    connect - check connectivity of remote host on specific port
        END_OF_USAGE

    def raise_message(action, message, *args)
      messages = {1 => "Please specify an action and optional arguments",
                  2 => "Action can only to be ping or connect",
                  3 => "Do you really want to perform network tests unfiltered? (y/n): "}

      send(action, messages[message] % args)
    end

    def post_option_parser(configuration)
      if ARGV.size < 2
        raise_message(:raise, 1)
      else
        action = ARGV.shift

        host_name = ARGV.shift
        remote_port = ARGV.shift

        if action =~ /^ping$/
          arguments = {:fqdn => host_name}
        elsif action =~  /^connect$/
          # Cast port to an integer since it will be coming in as a string from the cli
          arguments = {:fqdn => host_name, :port => DDL.string_to_number(remote_port)}
        else
          raise_message(:raise, 2)
        end

        configuration[:action] = action
        configuration[:arguments] = arguments
      end
    end

    def validate_configuration(configuration)
      if MCollective::Util.empty_filter?(options[:filter])
        raise_message(:print, 3)

        STDOUT.flush

        # Only match letter "y" or complete word "yes" ...
        exit(1) unless STDIN.gets.strip.match(/^(?:y|yes)$/i)
      end
    end

    def main
      nettest = rpcclient('nettest')
      nettest_result = nettest.send(configuration[:action], configuration[:arguments])

      nettest_result.each do |result|
        node = result[:data][:rtt] || result[:data][:connect]

        if result[:statuscode] == 0
          node = node.to_s
          case configuration[:action]
          when 'ping'
            if nettest.verbose
              puts "%-40s time = %s\t\t%s" % [result[:sender], node, result[:statusmsg]]
            else
              puts "%-40s time = %s" % [result[:sender], node]
            end
          when 'connect'
            if nettest.verbose
              puts "%-40s status = %s\t\t%s" % [result[:sender], node, result[:statusmsg]]
            else
              puts "%-40s status = %s" % [result[:sender], node]
            end
          end
        else
          puts "%-40s %s \t\t%s" % [result[:sender], node, result[:statusmsg]]
        end
      end

      puts
      printrpcstats :summarize => true, :caption => "%s Nettest results" % configuration[:action]
      halt(nettest.stats)
    end
  end
end
