module MCollective
  class Aggregate
    class Nettest_mma<Base
     def startup_hook
        @result[:value] = [0.0, 0.0, 0.0]
        @count = 0
        @result[:type] = :numeric

        # set default aggregate format unless it is defined
        @aggregate_format = "Min: %.3f  Max: %.3f  Average: %.3f" unless @aggregate_format
      end

      def process_result(value, reply)
        # Return from the method if the supplied value is not a numerical value
        value = Float(value) rescue return

        if value < @result[:value][0] || @result[:value][0] == 0.0
          @result[:value][0] = value
        end

        if value > @result[:value][1]
          @result[:value][1] = value
        end

        @count += 1
        @result[:value][2] += value
      end

      def summarize
        @result[:value][2] /= @count if @count > 1
        super
      end
    end
  end
end
