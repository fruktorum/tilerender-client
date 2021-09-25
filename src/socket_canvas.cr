require "http/server"
require "./version"

HTML_HEADERS = "<!DOCTYPE html><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><title>Graphics on Sockets!</title>"
HTML_SCRIPT_START = %q[<script type="text/javascript">]
HTML_SCRIPT_FINISH = "</script>"
HTML_BODY_START = "</head><body>"
HTML_BODY_FINISH = "</body></html>"

HTML_CSS = String.build{|string|
	string << "<style>"
	string << "#wrapper{position:absolute;left:10px;top:10px;right:10px;bottom:80px;overflow:scroll}"
	string << "#field{position:relative}"
	string << "#text{position:absolute;left:10px;bottom:10px;right:10px;height:60px;box-sizing:border-box;border:1px solid grey;overflow-y:scroll}"
	string << "#text span{display:block;overflow-wrap:break-word;font-family:monospace}"
	string << "#text span:nth-child(even){background-color:#f8efd2}"
	string << "#text span:nth-child(odd){background-color:#f5e8b8}"
	string << "</style>"
}

HTML_BODY = String.build{|string|
	string << %q[<div id="wrapper"><canvas id="field"></canvas></div>]
	string << %q[<div id="text"></div>]
}

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
		string << HTML_CSS
		string << HTML_BODY_START << HTML_BODY << HTML_BODY_FINISH
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
			status = Process.run "npm", %w[run build], output: stdout, error: stderr

			if status.success?
				body = HTML_BODY

				string << HTML_SCRIPT_START
				string << %Q[window.Config={wsPort:"#{ ENV[ "WS_PORT" ] }",production:false};]
				string << File.read( "assets/scripts/js/main.js" )
				string << HTML_SCRIPT_FINISH
			else
				body = %Q[<code style="white-space:pre-wrap">#{ stderr }</code>]
			end

			string << HTML_CSS << HTML_BODY_START << body << HTML_BODY_FINISH
		}
	end
{% end %}

server = HTTP::Server.new do |context|
	context.response.content_type = "text/html"

	if context.request.path == "/"
		context.response.print html_success_answer
	else
		context.response.status = HTTP::Status::NOT_FOUND
		context.response.print HTML_404
	end
end

puts "Preparing for listening"
address = server.bind_tcp "0.0.0.0", 80
puts "Listening on http://#{ address }, mode: #{ {{ flag?( :release ) ? "production" : "development" }} }"
server.listen
