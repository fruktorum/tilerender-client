require "http/server"
require "./version"

HTML_HEADERS       = "<!DOCTYPE html><html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><title>Graphics on Sockets!</title>"
HTML_SCRIPT_START  = %q[<script type="text/javascript">]
HTML_SCRIPT_FINISH = "</script>"
HTML_BODY_START    = "</head><body>"
HTML_BODY_FINISH   = "</body></html>"

HTML_CSS = String.build { |string|
  string << "<style>"
  string << "@font-face{font-family:\"Victor Mono\";src:url(\"/fonts/victormono.woff2\") format(\"woff2\"),url(\"/fonts/victormono.woff\") format(\"woff\")}"
  string << "#wrapper{position:absolute;left:10px;top:10px;right:10px;bottom:80px;overflow:scroll}"
  string << "#field{position:relative}"
  string << "#overlay{position:absolute;left:0;top:0;width:100%;height:100%;background-color:#edf0ee;opacity:.7}"
  string << "#overlay.hidden{display:none}"
  string << "#text{position:absolute;left:10px;right:10px;height:4.5rem;box-sizing:border-box;border:1px solid grey;border-radius:10px 5px 5px 10px;padding:0 5px;overflow-y:scroll;font-family:\"Victor Mono\";font-size:1rem;background-color:#fff8eb}"
  string << "#text::-webkit-scrollbar-track{box-shadow:inset 0 0 6px rgba(0,0,0,.7);border-radius:10px;background-color:#fcf8e8}"
  string << "#text::-webkit-scrollbar{width:12px;background-color:#f5f5f5;border-radius:10px}"
  string << "#text::-webkit-scrollbar-thumb{border-radius:10px;background-color:#d7005f;background-image:linear-gradient(0,transparent,rgba(0,0,0,.4) 50%,transparent,transparent)}"
  string << "#text.normal{bottom:10px}"
  string << "#text.fullscreen{top:50px;left:50px;right:50px;padding:5px;box-shadow:0 0 50px 3px #74746c}"
  string << "#text span{display:block;overflow-wrap:break-word}"
  string << "#text span.odd{background-color:#fff3d9}"
  string << "</style>"
}

HTML_BODY = String.build { |string|
  string << %q[<div id="wrapper"><canvas id="field"></canvas></div>]
  string << %q[<div id="overlay" class="hidden"></div>]
  string << %q[<div id="text" class="normal"></div>]
}

HTML_404 = String.build { |string|
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
    string << {{ read_file "assets/scripts/js/main.min.js" }}
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
      status = Process.run "yarn", %w[run compile], output: stdout, error: stderr

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
  error_404 = false

  case context.request.path
  when "/"
    result = html_success_answer
    context.response.content_type = "text/html"
    context.response.content_length = result.size
    context.response.print result
  when /^\/fonts/
    filename = {% if flag? :release %} ".#{ context.request.path }" {% else %} "assets#{ context.request.path }" {% end %}

    if File.exists? filename
      context.response.content_type = "font/#{filename[/[^\.]+$/]}"
      context.response.content_length = File.size filename
      File.open(filename, "rb") { |file| context.response.print file.gets_to_end }
    else
      error_404 = true
    end
  else
    error_404 = true
  end

  if error_404
    context.response.content_type = "text/html"
    context.response.content_length = HTML_404.size
    context.response.status = HTTP::Status::NOT_FOUND
    context.response.print HTML_404
  end
end

puts "Preparing for listening"
address = server.bind_tcp "0.0.0.0", 80
puts "Listening on http://#{address}, mode: #{{{ flag?(:release) ? "production" : "development" }}}"
server.listen
