require 'net/http'
require 'uri'

module MCollective
    module Agent
        class Fbstatus<RPC::Agent
            action "status" do
                response = get_monjsp
                reply.fail! unless response =~ /I am alive. Thank you for asking./
                reply[:msg] = "I am alive. Thank you for asking."
            end

            action "monitor" do
                validate :monitor, String
                validate :monitor, :shellsafe

                response = get_monjsp request[:monitor]
                reply[:msg] = scrub_response(response)
            end

            def scrub_response str
                str.match(/^.*=(.*)/)
                str = $1
                str.gsub!("\\/","/")
                str.gsub!("\^", " ")
                return str
            end

            def get_monjsp monitor = nil
                # mon.jsp base url.
                url = "http://localhost:8080/backstop/mon.jsp"
                url = url + "?monitors=#{monitor}" if monitor

                logger.debug "URL:  '#{url}'"
                logger.info "Requesting monitor:  '#{monitor}'"
                params = {"monitors" => monitor}
                Net::HTTP.get(URI.parse(url))
            end
        end
    end
end
