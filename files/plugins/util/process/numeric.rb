module MCollective
  module Util
    module Process
      class ::Numeric
        def bytes_to_human
          # Prevent nonsense values being returned for fractions
          if self >= 1
            units = ['B', 'KB', 'MB' ,'GB' ,'TB']
            e = (Math.log(self)/Math.log(1024)).floor
            # Cap at TB
            e = 4 if e > 4
            s = "%.3f " % (to_f / 1024**e)
            s.sub(/\.?0*$/, units[e])
          else
            "0 B"
          end
        end
      end
    end
  end
end
