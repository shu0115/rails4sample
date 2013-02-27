class ProgressController < ApplicationController
  include ActionController::Live

  def index
    response.headers['Content-Type'] = 'text/plain'

    begin
      (0..100).step(10).each{ |i|
        response.stream.write("#{i}\n")
        sleep(rand * 3)
      }
    rescue IOError
    ensure
      response.stream.close
    end
  end
end
