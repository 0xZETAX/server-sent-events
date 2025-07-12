# Ruby with Sinatra
require 'sinatra'
require 'json'
require 'time'

set :port, 3009
set :bind, '0.0.0.0'

# Enable CORS
before do
  headers 'Access-Control-Allow-Origin' => '*'
end

get '/events' do
  content_type 'text/event-stream'
  headers 'Cache-Control' => 'no-cache',
          'Connection' => 'keep-alive'

  stream(:keep_open) do |out|
    # Send initial message
    out << "data: Connected to Ruby Sinatra SSE\n\n"
    
    # Start background thread for periodic messages
    Thread.new do
      begin
        loop do
          message = {
            message: 'Hello from Ruby Sinatra',
            timestamp: Time.now.iso8601
          }
          
          out << "data: #{message.to_json}\n\n"
          sleep 2
        end
      rescue => e
        puts "Stream error: #{e}"
      end
    end
  end
end