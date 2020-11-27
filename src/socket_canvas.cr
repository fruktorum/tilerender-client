require "http/server"
require "./version"

HTML_HEADERS = "<!DOCTYPE html><html><head><title>Graphics on Sockets!</title>"
HTML_SCRIPT_START = %q[<script type="text/javascript">]
HTML_SCRIPT_FINISH = "</script>"
HTML_BODY_START = "</head><body>"
HTML_BODY_FINISH = "</body></html>"

HTML_404 = String.build{|string|
	string << HTML_HEADERS
	string << HTML_BODY_START
	string << "The page you're looking for does not exist"
	string << HTML_BODY_FINISH
}

{% if flag? :release %}
	HTML_CONTENT = String.build{|string|
		string << HTML_HEADERS
		string << HTML_SCRIPT_START
		string << "window.Config={wsPort:\"#{ ENV[ "WS_PORT" ] }\",production:true};"
		string << {{ read_file "assets/scripts/js/main.js" }}
		string << HTML_SCRIPT_FINISH
		string << HTML_BODY_START
		string << %q[<canvas id="field" style="position:absolute;left:10px;top:10px"></canvas>]
		string << HTML_BODY_FINISH
	}

	macro html_success_answer
		HTML_CONTENT
	end
{% else %}
	macro html_success_answer
		String.build{|string|
			string << HTML_HEADERS

			stdout = IO::Memory.new
			stderr = IO::Memory.new
			status = Process.run "npm", \\%w[run build], output: stdout, error: stderr

			if status.success?
				body = %q[<canvas id="field" style="position:absolute;left:10px;top:10px"></canvas>]

				string << HTML_SCRIPT_START
				string << "window.Config={wsPort:\"#{ ENV[ "WS_PORT" ] }\",production:false};"
				string << File.read( "assets/scripts/js/main.js" )
				string << HTML_SCRIPT_FINISH
			else
				body = "<code style=\"white-space:pre-wrap\">#{ stderr }</code>"
			end

			string << HTML_BODY_START << body << HTML_BODY_FINISH
		}
	end
{% end %}

macro error_404( context )
end

server = HTTP::Server.new do |context|
	if context.request.path == "/"
		context.response.content_type = "text/html"
		context.response.print html_success_answer
	else
		context.response.status = HTTP::Status::NOT_FOUND
		context.response.content_type = "text/html"
		context.response.print HTML_404
	end
end

puts "Preparing for listening"
address = server.bind_tcp "0.0.0.0", 80
puts "Listening on http://#{ address }, mode: #{ {{ flag?( :release ) ? "production" : "development" }} }"
server.listen
