module MCollective
  class Aggregate
    class Process_summary<Base
      def startup_hook
        PluginManager.loadclass('MCollective::Util::Process::Numeric')
        # Hosts, count, rss, vsize
        result[:value] = [0, 0, 0, 0]
        @result[:type] = :numeric
      end

      def process_result(value, reply)
        result[:value][0] += 1 unless value.empty?

        value.each do |v|
          result[:value][1] += 1
          result[:value][2] += v[:rss] * 1024
          result[:value][3] += v[:vsize]
        end
      end

      def summarize
        result[:value][2] = result[:value][2].bytes_to_human
        result[:value][3] = result[:value][3].bytes_to_human

        result_string = StringIO.new
        result_string.puts "        Matched hosts: %s"
        result_string.puts "    Matched Processes: %s"
        result_string.puts "        Resident Size: %s"
        result_string.puts "         Virtual Size: %s"

        @aggregate_format = result_string.string
        super
      end
    end
  end
end
