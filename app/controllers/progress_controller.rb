class ProgressController < ApplicationController
  include ActionController::Live

  def index
    response.headers['Content-Type'] = 'text/plain'

    begin
#      (0..100).step(10).each do |i|
      (0..50).step(10).each do |i|
        response.stream.write("#{i}\n")
        sleep(rand * 3)
      end

    rescue IOError

    ensure
      response.stream.close
    end
  end
end
