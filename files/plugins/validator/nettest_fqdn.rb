module MCollective
  module Validator
    class Nettest_fqdnValidator
      def self.validate(validator)
        begin
          ip = ! Validator.validate(validator, :ipv4address) rescue false
          hostname_regxp = /\A^(([a-zA-Z]|[a-zA-Z][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z]|[A-Za-z][A-Za-z0-9\-]*[A-Za-z0-9])$\z/

          raise unless ip || validator =~ hostname_regxp
        rescue
          raise ValidatorError, "value should be a valid fqdn"
        end
      end
    end
  end
end
