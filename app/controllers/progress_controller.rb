require 'reloader/sse'

class ProgressController < ApplicationController
  include ActionController::Live

  def index
    # SSE expects the `text/event-stream` content type
    response.headers['Content-Type'] = 'text/event-stream'

    sse = Reloader::SSE.new(response.stream)

    begin
      (0..100).step(10).each{ |i|
        puts "[ #{i} ]"
        sse.write( "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}" + " - #{i}" )
        sleep( rand(1..3) )
      }

      # 接続終了送信
#      sse.write("stream_end")
    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      sse.close
    end
  end

  def show
  end
end
