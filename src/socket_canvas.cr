require "http/server"
require "./version"

HTML_HEADERS = "<!DOCTYPE html><html><head><title>Graphics on Sockets!</title>"
HTML_SCRIPT_START = %q[<script type="text/javascript">]
HTML_SCRIPT_FINISH = "</script>"
HTML_BODY_START = "</head><body>"
HTML_BODY_FINISH = "</body></html>"

{% if flag? :release %}
	HTML_CONTENT = String.build{|string|
		body = %q[<canvas id="field" style="position:absolute;left:10px;top:10px"></canvas>]

		string << HTML_HEADERS
		string << HTML_SCRIPT_START
		string << "window.Config={wsPort:\"#{ ENV[ "WS_PORT" ] }\",production:true};"
		string << {{ read_file "assets/scripts/js/main.js" }}
		string << HTML_SCRIPT_FINISH
		string << HTML_BODY_START << body << HTML_BODY_FINISH
	}
{% end %}

server = HTTP::Server.new do |context|
	context.response.content_type = "text/html"
	context.response.print(
		{% if flag? :release %} HTML_CONTENT {% else %}
			String.build{|string|
				string << HTML_HEADERS

				if ( compile_result = `npm run compile 1>/dev/null 2>/dev/stdout` ).empty? && ( compile_result = `npm run transpile 1>/dev/null 2>/dev/stdout` ).empty?
					body = %q[<canvas id="field" style="position:absolute;left:10px;top:10px"></canvas>]

					string << HTML_SCRIPT_START
					string << "window.Config={wsPort:\"#{ ENV[ "WS_PORT" ] }\",production:false};"
					string << File.read( "assets/scripts/js/main.js" )
					string << HTML_SCRIPT_FINISH
				else
					body = "<code style=\"white-space:pre-wrap\">#{ compile_result }</code>"
				end

				string << HTML_BODY_START << body << HTML_BODY_FINISH
			}
		{% end %}
	)
end

puts "Preparing for listening"
address = server.bind_tcp "0.0.0.0", 80
puts "Listening on http://#{ address }, mode: #{ {{ flag?( :release ) ? "production" : "development" }} }"
server.listen
