module  MCollective
  class Application
    class Process<Application
      description 'Distributed Process Management'
      usage 'mco pgrep <pattern> [-z] [--fields=FIELDS]'

      option :just_zombies,
             :description => 'Only list defunct processes',
             :arguments   => ['-z', '--zombies'],
             :type        => :bool

      option :fields,
             :description => 'Comma seperated list of outputs to display',
             :arguments   => ['--fields=FIELDS'],
             :type        => Array

      option :silent,
             :description => 'Quietly displays the summary of the list',
             :arguments   => ['--silent'],
             :type        => :bool

      def handle_message(action, message, *args)
        messages = {1 => 'Please provide an action',
                    2 => "'%s' specified as process field. Valid options are %s",
                    3 => "Invalid action. Valid action is 'list'"}

        send(action, messages[message] % args)
      end

      def post_option_parser(configuration)
        handle_message(:raise, 1) if ARGV.size == 0
        configuration[:action] = ARGV.shift
        handle_message(:raise, 2) unless configuration[:action] == 'list'
        configuration[:pattern] = ARGV.shift || '.'

        unless configuration[:fields]
          config = Config.instance

          if fields = config.pluginconf.fetch('process.fields', nil)
            configuration[:fields] = fields.gsub(' ', '').split(',')
          else
            configuration[:fields] = ['pid', 'user', 'vsz', 'command']
          end
        end

        configuration[:just_zombies] = !! configuration[:just_zombies]
        configuration[:fields].map!{|output| output.upcase}
      end

      def validate_configuration(configuration)
        valid_fields = ['PID', 'USER', 'VSZ', 'COMMAND', 'TTY', 'RSS', 'STATE']
        configuration[:fields].each do |f|
          unless valid_fields.include?(f)
            handle_message(:raise, 2, f, valid_fields.join(', '))
          end
        end
      end

      def fields(field_names, process)
        f = {'PID'     => process[:pid],
             'USER'    => process[:username][0,10],
             'VSZ'     => process[:vsize].bytes_to_human,
             'COMMAND' => ( (process[:state] == 'Z') ? "[#{process[:cmdline]}]" : process[:cmdline])[0,60],
             'TTY'     => process[:tty_nr],
             'RSS'     => (process[:rss] * 1024).bytes_to_human,
             'STATE'   => process[:state]
        }

        field_names.map{|x| f[x]}
      end

      def main
        PluginManager.loadclass('MCollective::Util::Process::Numeric')
        ps = rpcclient('process')
        ps_result = ps.send(configuration[:action], :pattern => configuration[:pattern], :just_zombies => configuration[:just_zombies])
        ps_fields = configuration[:fields]
        field_size = Array.new(ps_fields.size).fill(0) {|i| ps_fields[i].size}
        final_output = {}

        ps_result.each do |result|
          if result[:statuscode] == 0
            unless configuration[:silent]
              next if result[:data][:pslist].empty?

              final_output[result[:sender]] = []

              result[:data][:pslist].each do |process|
                outputfields = fields(ps_fields, process)

                outputfields.each_with_index do |field, i|
                  field_size[i] = field.to_s.size if field.to_s.size > field_size[i]
                end.join

                final_output[result[:sender]] << outputfields
              end
            end

          else
            puts "   %-10s%20s" % [result[:sender], result[:statusmsg]]
          end
        end

        final_output.each do |k,v|
          puts "   %s" % k
          puts
          pattern = ("     %%-%ds" * ps_fields.size) % field_size
          puts pattern  % ps_fields
          v.each{|value| puts pattern % value}
          puts
        end

        puts

        printrpcstats(:summarize => true, :caption => "%s Process results" % configuration[:action])
        halt(ps.stats)
      end
    end
  end
end
