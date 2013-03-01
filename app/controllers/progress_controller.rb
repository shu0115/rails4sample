require 'reloader/sse'

class ProgressController < ApplicationController
  include ActionController::Live

  #-------#
  # index #
  #-------#
  def index
    # SSE expects the `text/event-stream` content type
    response.headers['Content-Type'] = 'text/event-stream'

    sse = Reloader::SSE.new(response.stream)

    begin
      total = 0

      (0..100).step(10).each{ |i|
        puts "[ #{i} ]"
        sse.write( "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}" + " - #{i}" )
        total += i
        sleep( rand(1..3) )
      }

      puts "[ total : #{total} ]"

      sse.write( "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}" + " - #{total}", event: 'refresh' )

      # 接続終了送信
#      sse.write("stream_end")
    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      sse.close
    end
  end

  #------#
  # show #
  #------#
  def show
  end

  #--------#
  # attack #
  #--------#
  def attack
    response.headers['Content-Type'] = 'text/event-stream'
    sse = Reloader::SSE.new(response.stream)

    begin
#      url  = "https://canbus.herokuapp.com/"
      url  = "https://canbus.herokuapp.com/canvas"
      url  = URI.parse( url )
      http = Net::HTTP.new( url.host, url.port )
      http.use_ssl = true if url.port == 443
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if url.port == 443
      path = url.path
      path += "?" + url.query unless url.query.nil?

      str = ""

      1.upto(10){ |i|
        response = http.get( path )
        status   = response.inspect.delete("#<>")
        str      = "[ #{i} | #{Time.now.strftime("%Y/%m/%d %H:%M:%S")}" + " | #{url} | #{status} | #{$all_stop} ]"
        puts str
      }

      sse.write( str, event: 'refresh' )

      # 接続終了送信
      if session[:realtime_end] == true or $all_stop.present?
        sse.write( "stream_end", event: 'refresh' )
      end
    rescue IOError
      # When the client disconnects, we'll get an IOError on write
    ensure
      sse.close
    end
  end

  #-------------#
  # attack_show #
  #-------------#
  def attack_show
    session[:realtime_end] = false
  end

  #------------#
  # attack_end #
  #------------#
  def attack_end
    $all_stop = params[:all_stop]
    session[:realtime_end] = true
  end
end
